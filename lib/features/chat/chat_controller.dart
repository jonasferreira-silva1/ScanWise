import 'package:flutter/material.dart';
import '../../core/services/claude_service.dart';
import '../../core/services/firebase_service.dart';
import '../../models/chat_message.dart';

/// Gerencia o estado do chat financeiro com o assistente FinZen.
///
/// Mantém o histórico de mensagens para exibição na UI e o histórico
/// no formato da API do Claude para manter contexto entre perguntas.
class ChatController extends ChangeNotifier {
  final _claude = ClaudeService();
  final _firebase = FirebaseService();

  /// Mensagens exibidas na UI (usuário + assistente).
  final List<ChatMessage> mensagens = [];

  /// Histórico no formato da API do Claude: [{role, content}, ...]
  /// Mantém o contexto da conversa entre chamadas.
  final List<Map<String, String>> _historicoClaude = [];

  bool _digitando = false;
  bool get digitando => _digitando;

  bool _carregando = false;
  bool get carregando => _carregando;

  /// Inicializa o chat com a mensagem de boas-vindas do assistente.
  ChatController() {
    _adicionarBoasVindas();
  }

  // ---------------------------------------------------------------------------
  // Envio de mensagem
  // ---------------------------------------------------------------------------

  /// Envia uma pergunta ao assistente e aguarda a resposta.
  ///
  /// Busca o contexto financeiro real do Firestore antes de cada chamada
  /// para que o Claude sempre responda com dados atualizados.
  Future<void> enviar(String pergunta) async {
    final texto = pergunta.trim();
    if (texto.isEmpty || _carregando) return;

    // Adiciona mensagem do usuário imediatamente na UI
    mensagens.add(ChatMessage(texto: texto, isUser: true));
    _setDigitando(true);

    try {
      // Busca resumo financeiro atual para injetar no prompt
      final contexto = await _firebase.gerarContextoFinanceiro();

      // Chama o Claude com histórico completo para manter contexto
      final resposta = await _claude.chat(
        historico: _historicoClaude,
        pergunta: texto,
        contextoDados: contexto,
      );

      // Atualiza histórico da API para a próxima chamada
      _historicoClaude.add({'role': 'user', 'content': texto});
      _historicoClaude.add({'role': 'assistant', 'content': resposta});

      // Limita o histórico a 20 mensagens para não estourar tokens
      if (_historicoClaude.length > 20) {
        _historicoClaude.removeRange(0, 2);
      }

      mensagens.add(ChatMessage(texto: resposta, isUser: false));
    } catch (e) {
      mensagens.add(ChatMessage(
        texto: 'Desculpe, tive um problema ao processar sua pergunta. Tente novamente.',
        isUser: false,
      ));
    } finally {
      _setDigitando(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Utilitários
  // ---------------------------------------------------------------------------

  /// Limpa o histórico e reinicia o chat com a mensagem de boas-vindas.
  void limparConversa() {
    mensagens.clear();
    _historicoClaude.clear();
    _adicionarBoasVindas();
    notifyListeners();
  }

  void _adicionarBoasVindas() {
    mensagens.add(ChatMessage(
      texto:
          'Olá! Sou o FinZen, seu assistente financeiro pessoal. '
          'Posso ajudar você a entender seus gastos, analisar categorias '
          'e dar dicas de economia. Como posso ajudar hoje?',
      isUser: false,
    ));
  }

  void _setDigitando(bool valor) {
    _digitando = valor;
    _carregando = valor;
    notifyListeners();
  }
}
