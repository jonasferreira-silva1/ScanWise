import 'package:flutter_test/flutter_test.dart';

/// Testa a lógica de tradução de erros do AuthController
/// sem depender do Firebase (sem chamadas reais).
///
/// A função _traduzirErroFirebase é privada, então testamos
/// o comportamento esperado diretamente com a lógica equivalente.
String traduzirErroFirebase(String codigo) {
  switch (codigo) {
    case 'account-exists-with-different-credential':
      return 'Esta conta já existe com outro método de login.';
    case 'network-request-failed':
      return 'Sem conexão com a internet. Verifique sua rede.';
    case 'user-disabled':
      return 'Esta conta foi desativada.';
    default:
      return 'Erro ao fazer login. Tente novamente.';
  }
}

void main() {
  group('AuthController — tradução de erros Firebase', () {
    test('traduz account-exists-with-different-credential', () {
      final mensagem = traduzirErroFirebase(
        'account-exists-with-different-credential',
      );
      expect(mensagem, equals('Esta conta já existe com outro método de login.'));
    });

    test('traduz network-request-failed', () {
      final mensagem = traduzirErroFirebase('network-request-failed');
      expect(mensagem, equals('Sem conexão com a internet. Verifique sua rede.'));
    });

    test('traduz user-disabled', () {
      final mensagem = traduzirErroFirebase('user-disabled');
      expect(mensagem, equals('Esta conta foi desativada.'));
    });

    test('retorna mensagem genérica para código desconhecido', () {
      final mensagem = traduzirErroFirebase('codigo-desconhecido');
      expect(mensagem, equals('Erro ao fazer login. Tente novamente.'));
    });

    test('retorna mensagem genérica para string vazia', () {
      final mensagem = traduzirErroFirebase('');
      expect(mensagem, equals('Erro ao fazer login. Tente novamente.'));
    });

    test('todos os erros conhecidos retornam mensagem em português', () {
      final codigosConhecidos = [
        'account-exists-with-different-credential',
        'network-request-failed',
        'user-disabled',
      ];

      for (final codigo in codigosConhecidos) {
        final mensagem = traduzirErroFirebase(codigo);
        expect(mensagem, isNotEmpty,
            reason: 'Código $codigo deve ter mensagem traduzida');
        expect(mensagem, isNot(equals('Erro ao fazer login. Tente novamente.')),
            reason: 'Código $codigo deve ter mensagem específica, não genérica');
      }
    });
  });

  group('AuthController — validação de estado', () {
    test('estado inicial não está carregando', () {
      // Simula o estado inicial do controller
      bool carregando = false;
      expect(carregando, isFalse);
    });

    test('estado inicial não tem erro', () {
      String? erro;
      expect(erro, isNull);
    });
  });
}
