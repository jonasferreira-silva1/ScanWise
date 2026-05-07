import 'package:flutter_test/flutter_test.dart';
import 'package:finzen/models/transaction.dart';

void main() {
  // Transação base reutilizada nos testes
  final transacaoBase = Transaction(
    id: 'test-id-001',
    valor: 150.50,
    descricao: 'Supermercado Extra',
    categoria: 'Alimentação',
    data: DateTime(2026, 5, 7),
    uid: 'uid-usuario-001',
  );

  group('Transaction.toMap()', () {
    test('converte todos os campos corretamente', () {
      final mapa = transacaoBase.toMap();

      expect(mapa['id'], equals('test-id-001'));
      expect(mapa['valor'], equals(150.50));
      expect(mapa['descricao'], equals('Supermercado Extra'));
      expect(mapa['categoria'], equals('Alimentação'));
      expect(mapa['data'], equals('2026-05-07T00:00:00.000'));
      expect(mapa['uid'], equals('uid-usuario-001'));
    });

    test('data é serializada no formato ISO 8601', () {
      final mapa = transacaoBase.toMap();
      // Garante que a data pode ser parseada de volta
      expect(() => DateTime.parse(mapa['data'] as String), returnsNormally);
    });
  });

  group('Transaction.fromMap()', () {
    test('reconstrói a transação a partir do mapa do Firestore', () {
      final mapa = {
        'id': 'test-id-001',
        'valor': 150.50,
        'descricao': 'Supermercado Extra',
        'categoria': 'Alimentação',
        'data': '2026-05-07T00:00:00.000',
        'uid': 'uid-usuario-001',
      };

      final transacao = Transaction.fromMap(mapa);

      expect(transacao.id, equals('test-id-001'));
      expect(transacao.valor, equals(150.50));
      expect(transacao.descricao, equals('Supermercado Extra'));
      expect(transacao.categoria, equals('Alimentação'));
      expect(transacao.data, equals(DateTime(2026, 5, 7)));
      expect(transacao.uid, equals('uid-usuario-001'));
    });

    test('converte valor inteiro do Firestore para double', () {
      // Firestore pode retornar int quando o valor não tem centavos
      final mapa = {
        'id': 'id',
        'valor': 100, // int, não double
        'descricao': 'Teste',
        'categoria': 'Outros',
        'data': '2026-05-01T00:00:00.000',
        'uid': 'uid',
      };

      final transacao = Transaction.fromMap(mapa);
      expect(transacao.valor, isA<double>());
      expect(transacao.valor, equals(100.0));
    });
  });

  group('Transaction — ida e volta (toMap → fromMap)', () {
    test('serialização e deserialização preservam todos os dados', () {
      final mapa = transacaoBase.toMap();
      final reconstruida = Transaction.fromMap(mapa);

      expect(reconstruida.id, equals(transacaoBase.id));
      expect(reconstruida.valor, equals(transacaoBase.valor));
      expect(reconstruida.descricao, equals(transacaoBase.descricao));
      expect(reconstruida.categoria, equals(transacaoBase.categoria));
      expect(reconstruida.data, equals(transacaoBase.data));
      expect(reconstruida.uid, equals(transacaoBase.uid));
    });
  });

  group('Transaction.copyWith()', () {
    test('cria cópia com valor alterado mantendo os demais campos', () {
      final copia = transacaoBase.copyWith(valor: 200.00);

      expect(copia.valor, equals(200.00));
      expect(copia.id, equals(transacaoBase.id));
      expect(copia.descricao, equals(transacaoBase.descricao));
      expect(copia.categoria, equals(transacaoBase.categoria));
      expect(copia.uid, equals(transacaoBase.uid));
    });

    test('cria cópia com categoria alterada', () {
      final copia = transacaoBase.copyWith(categoria: 'Transporte');
      expect(copia.categoria, equals('Transporte'));
      expect(copia.valor, equals(transacaoBase.valor));
    });

    test('sem argumentos retorna cópia idêntica', () {
      final copia = transacaoBase.copyWith();

      expect(copia.id, equals(transacaoBase.id));
      expect(copia.valor, equals(transacaoBase.valor));
      expect(copia.descricao, equals(transacaoBase.descricao));
    });

    test('não modifica o objeto original', () {
      transacaoBase.copyWith(valor: 999.99);
      expect(transacaoBase.valor, equals(150.50));
    });
  });
}
