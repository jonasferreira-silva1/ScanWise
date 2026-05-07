import 'package:flutter_test/flutter_test.dart';
import 'package:finzen/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('cria mensagem do usuário corretamente', () {
      final mensagem = ChatMessage(
        texto: 'Quanto gastei esse mês?',
        isUser: true,
      );

      expect(mensagem.texto, equals('Quanto gastei esse mês?'));
      expect(mensagem.isUser, isTrue);
      expect(mensagem.timestamp, isA<DateTime>());
    });

    test('cria mensagem do assistente corretamente', () {
      final mensagem = ChatMessage(
        texto: 'Você gastou R\$ 500,00 este mês.',
        isUser: false,
      );

      expect(mensagem.isUser, isFalse);
      expect(mensagem.texto, contains('R\$'));
    });

    test('timestamp é definido automaticamente quando não fornecido', () {
      final antes = DateTime.now();
      final mensagem = ChatMessage(texto: 'Teste', isUser: true);
      final depois = DateTime.now();

      expect(
        mensagem.timestamp.isAfter(antes) ||
            mensagem.timestamp.isAtSameMomentAs(antes),
        isTrue,
      );
      expect(
        mensagem.timestamp.isBefore(depois) ||
            mensagem.timestamp.isAtSameMomentAs(depois),
        isTrue,
      );
    });

    test('timestamp personalizado é preservado', () {
      final dataEspecifica = DateTime(2026, 5, 7, 10, 30);
      final mensagem = ChatMessage(
        texto: 'Teste',
        isUser: true,
        timestamp: dataEspecifica,
      );

      expect(mensagem.timestamp, equals(dataEspecifica));
    });

    test('mensagem vazia é permitida', () {
      final mensagem = ChatMessage(texto: '', isUser: true);
      expect(mensagem.texto, equals(''));
    });

    test('mensagem longa é preservada integralmente', () {
      final textoLongo = 'A ' * 500; // 1000 caracteres
      final mensagem = ChatMessage(texto: textoLongo, isUser: false);
      expect(mensagem.texto, equals(textoLongo));
    });
  });
}
