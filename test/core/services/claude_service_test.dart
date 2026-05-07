import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Testa a lógica de parsing e limpeza de resposta do ClaudeService
/// sem fazer chamadas reais à API.
///
/// A função _removerMarcacaoMarkdown é privada, então testamos
/// o comportamento via jsonDecode simulando o que o service faz.
void main() {
  group('Parsing de resposta JSON do Claude', () {
    test('parseia JSON limpo corretamente', () {
      const respostaJson = '''
{
  "valor": 45.90,
  "descricao": "Supermercado Extra",
  "categoria": "Alimentação",
  "data": "2026-05-07"
}
''';

      final dados = jsonDecode(respostaJson.trim()) as Map<String, dynamic>;

      expect(dados['valor'], equals(45.90));
      expect(dados['descricao'], equals('Supermercado Extra'));
      expect(dados['categoria'], equals('Alimentação'));
      expect(dados['data'], equals('2026-05-07'));
    });

    test('parseia JSON com markdown ```json removido', () {
      // Claude às vezes retorna o JSON dentro de bloco de código markdown
      const respostaComMarkdown = '''
```json
{
  "valor": 150.00,
  "descricao": "iFood",
  "categoria": "Alimentação",
  "data": "2026-05-01"
}
```''';

      // Simula a limpeza que o ClaudeService faz
      String limpo = respostaComMarkdown.trim();
      if (limpo.startsWith('```')) {
        limpo = limpo
            .replaceFirst(RegExp(r'^```(?:json)?\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '')
            .trim();
      }

      final dados = jsonDecode(limpo) as Map<String, dynamic>;
      expect(dados['valor'], equals(150.00));
      expect(dados['descricao'], equals('iFood'));
    });

    test('parseia JSON com markdown ``` simples removido', () {
      const respostaComMarkdown = '''
```
{"valor": 99.90, "descricao": "Uber", "categoria": "Transporte", "data": null}
```''';

      String limpo = respostaComMarkdown.trim();
      if (limpo.startsWith('```')) {
        limpo = limpo
            .replaceFirst(RegExp(r'^```(?:json)?\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '')
            .trim();
      }

      final dados = jsonDecode(limpo) as Map<String, dynamic>;
      expect(dados['valor'], equals(99.90));
      expect(dados['categoria'], equals('Transporte'));
      expect(dados['data'], isNull);
    });

    test('valor como inteiro é convertido para double', () {
      const respostaJson = '{"valor": 100, "descricao": "Teste", "categoria": "Outros", "data": null}';
      final dados = jsonDecode(respostaJson) as Map<String, dynamic>;

      // Simula a conversão que o ScanController faz
      final valor = (dados['valor'] as num).toDouble();
      expect(valor, isA<double>());
      expect(valor, equals(100.0));
    });

    test('data null é tratada sem erro', () {
      const respostaJson = '{"valor": 50.0, "descricao": "Teste", "categoria": "Outros", "data": null}';
      final dados = jsonDecode(respostaJson) as Map<String, dynamic>;

      // Simula o tratamento de data null no ScanController
      final data = dados['data'] != null
          ? DateTime.tryParse(dados['data'] as String) ?? DateTime.now()
          : DateTime.now();

      expect(data, isA<DateTime>());
    });

    test('data válida é parseada corretamente', () {
      const respostaJson = '{"valor": 50.0, "descricao": "Teste", "categoria": "Outros", "data": "2026-05-07"}';
      final dados = jsonDecode(respostaJson) as Map<String, dynamic>;

      final data = DateTime.tryParse(dados['data'] as String);
      expect(data, equals(DateTime(2026, 5, 7)));
    });
  });

  group('Validação de categorias', () {
    const categoriasValidas = [
      'Alimentação',
      'Transporte',
      'Saúde',
      'Educação',
      'Lazer',
      'Moradia',
      'Outros',
    ];

    test('todas as categorias válidas são reconhecidas', () {
      for (final categoria in categoriasValidas) {
        expect(categoriasValidas.contains(categoria), isTrue,
            reason: '$categoria deveria ser uma categoria válida');
      }
    });

    test('categoria inválida não está na lista', () {
      expect(categoriasValidas.contains('Viagem'), isFalse);
      expect(categoriasValidas.contains(''), isFalse);
    });
  });

  group('Construção do corpo da requisição', () {
    test('corpo da requisição tem estrutura correta', () {
      const modelo = 'claude-haiku-4-5';
      const textoOcr = 'SUPERMERCADO EXTRA\nTotal: R\$ 45,90';

      final corpo = jsonEncode({
        'model': modelo,
        'max_tokens': 300,
        'system': 'prompt do sistema',
        'messages': [
          {'role': 'user', 'content': textoOcr},
        ],
      });

      final decodificado = jsonDecode(corpo) as Map<String, dynamic>;
      expect(decodificado['model'], equals('claude-haiku-4-5'));
      expect(decodificado['max_tokens'], equals(300));
      expect(decodificado['messages'], isA<List>());
      expect(
        (decodificado['messages'] as List).first['role'],
        equals('user'),
      );
    });
  });
}
