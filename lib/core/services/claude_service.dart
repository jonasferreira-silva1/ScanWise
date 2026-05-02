import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Serviço responsável por toda comunicação com a Claude API (Anthropic).
///
/// Em desenvolvimento: usa a chave do arquivo .env diretamente.
/// Em produção: substitua as chamadas http pelo proxy via Cloud Functions
/// para que a chave nunca fique exposta no app compilado.
class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  /// Modelo usado: claude-haiku — mais rápido e econômico, ideal para mobile.
  /// Troque para claude-sonnet se precisar de respostas mais elaboradas.
  static const String _modelo = 'claude-haiku-4-5';

  /// Cabeçalhos obrigatórios pela API da Anthropic.
  Map<String, String> get _cabecalhos => {
        'Content-Type': 'application/json',
        'x-api-key': dotenv.env['CLAUDE_API_KEY'] ?? '',
        'anthropic-version': '2023-06-01',
      };

  // ---------------------------------------------------------------------------
  // Extração de transação a partir de texto OCR
  // ---------------------------------------------------------------------------

  /// Envia o texto extraído por OCR para o Claude e recebe os dados
  /// financeiros estruturados (valor, descrição, categoria, data).
  ///
  /// Retorna um Map com as chaves: valor, descricao, categoria, data.
  /// Lança [Exception] em caso de falha na API ou resposta inválida.
  Future<Map<String, dynamic>> extrairTransacao(String textoOcr) async {
    const promptSistema = '''
Você é um assistente financeiro especializado em extrair dados de comprovantes brasileiros.

Dado um texto extraído por OCR de uma nota fiscal, comprovante de PIX ou extrato bancário,
retorne APENAS um JSON válido com esta estrutura exata:

{
  "valor": 0.00,
  "descricao": "nome do estabelecimento ou descrição da transação",
  "categoria": "uma de: Alimentação, Transporte, Saúde, Educação, Lazer, Moradia, Outros",
  "data": "YYYY-MM-DD ou null se não encontrar"
}

Regras:
- "valor" deve ser um número decimal (ex: 45.90), nunca string
- "descricao" deve ser curta e legível (máximo 50 caracteres)
- "categoria" deve ser exatamente uma das opções listadas
- Nenhum texto fora do JSON. Apenas o objeto JSON.
''';

    final corpo = jsonEncode({
      'model': _modelo,
      'max_tokens': 300,
      'system': promptSistema,
      'messages': [
        {'role': 'user', 'content': textoOcr},
      ],
    });

    try {
      final resposta = await http.post(
        Uri.parse(_baseUrl),
        headers: _cabecalhos,
        body: corpo,
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
        final texto = dados['content'][0]['text'] as String;

        // Claude pode retornar o JSON com markdown — remove se necessário
        final jsonLimpo = _removerMarcacaoMarkdown(texto);
        return jsonDecode(jsonLimpo) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Erro na API do Claude: ${resposta.statusCode} — ${resposta.body}',
        );
      }
    } on FormatException catch (e) {
      throw Exception('Resposta do Claude não é um JSON válido: $e');
    } catch (e) {
      throw Exception('Falha ao extrair transação: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Chat financeiro com histórico de contexto
  // ---------------------------------------------------------------------------

  /// Envia uma pergunta ao assistente financeiro com contexto dos gastos reais.
  ///
  /// [historico] — lista de mensagens anteriores para manter o contexto
  /// [pergunta] — nova mensagem do usuário
  /// [contextoDados] — resumo dos gastos do mês, injetado no system prompt
  ///
  /// Retorna a resposta do assistente como String.
  Future<String> chat({
    required List<Map<String, String>> historico,
    required String pergunta,
    required String contextoDados,
  }) async {
    final promptSistema = '''
Você é o FinZen, um assistente financeiro pessoal simpático e direto.

Dados financeiros do usuário este mês:
$contextoDados

Instruções:
- Responda em português brasileiro, de forma clara e objetiva
- Dê conselhos práticos quando relevante
- Seja encorajador, nunca crítico ou julgador
- Se não tiver dados suficientes para responder, diga isso claramente
- Mantenha respostas concisas (máximo 3 parágrafos)
''';

    // Monta o histórico completo com a nova pergunta no final
    final mensagens = [
      ...historico,
      {'role': 'user', 'content': pergunta},
    ];

    final corpo = jsonEncode({
      'model': _modelo,
      'max_tokens': 500,
      'system': promptSistema,
      'messages': mensagens,
    });

    try {
      final resposta = await http.post(
        Uri.parse(_baseUrl),
        headers: _cabecalhos,
        body: corpo,
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
        return dados['content'][0]['text'] as String;
      } else {
        throw Exception(
          'Erro na API do Claude: ${resposta.statusCode} — ${resposta.body}',
        );
      }
    } catch (e) {
      throw Exception('Falha no chat: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Utilitários privados
  // ---------------------------------------------------------------------------

  /// Remove marcação de bloco de código markdown (```json ... ```) se presente.
  /// O Claude às vezes envolve o JSON em markdown mesmo sendo instruído a não fazer.
  String _removerMarcacaoMarkdown(String texto) {
    final limpo = texto.trim();
    if (limpo.startsWith('```')) {
      return limpo
          .replaceFirst(RegExp(r'^```(?:json)?\n?'), '')
          .replaceFirst(RegExp(r'\n?```$'), '')
          .trim();
    }
    return limpo;
  }
}
