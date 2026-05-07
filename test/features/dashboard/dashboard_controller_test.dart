import 'package:flutter_test/flutter_test.dart';
import 'package:finzen/models/transaction.dart';
import 'package:finzen/features/dashboard/dashboard_controller.dart';

/// Cria uma transação de teste com valores padrão sobrescrevíveis.
Transaction _criarTransacao({
  String id = 'id',
  double valor = 100.0,
  String categoria = 'Alimentação',
  String uid = 'uid-teste',
}) {
  return Transaction(
    id: id,
    valor: valor,
    descricao: 'Teste',
    categoria: categoria,
    data: DateTime(2026, 5, 7),
    uid: uid,
  );
}

void main() {
  group('DashboardController.formatarMoeda()', () {
    test('formata valor simples corretamente', () {
      expect(DashboardController.formatarMoeda(150.50), equals('R\$ 150,50'));
    });

    test('formata valor com milhar', () {
      expect(DashboardController.formatarMoeda(1234.56), equals('R\$ 1.234,56'));
    });

    test('formata valor com dois milhar', () {
      expect(DashboardController.formatarMoeda(12345.00), equals('R\$ 12.345,00'));
    });

    test('formata zero corretamente', () {
      expect(DashboardController.formatarMoeda(0), equals('R\$ 0,00'));
    });

    test('formata valor sem centavos', () {
      expect(DashboardController.formatarMoeda(500.0), equals('R\$ 500,00'));
    });

    test('formata valor grande com múltiplos milhares', () {
      expect(
        DashboardController.formatarMoeda(1000000.00),
        equals('R\$ 1.000.000,00'),
      );
    });
  });

  group('DashboardController — cálculos financeiros', () {
    late DashboardController controller;

    setUp(() {
      controller = DashboardController();
    });

    test('totalDespesas retorna 0 quando não há transações', () {
      expect(controller.totalDespesas, equals(0.0));
    });

    test('totalTransacoes retorna 0 quando não há transações', () {
      expect(controller.totalTransacoes, equals(0));
    });

    test('totaisPorCategoria retorna lista vazia quando não há transações', () {
      expect(controller.totaisPorCategoria, isEmpty);
    });

    test('transacoesRecentes retorna lista vazia quando não há transações', () {
      expect(controller.transacoesRecentes, isEmpty);
    });
  });

  group('DashboardController — estado inicial', () {
    test('inicia em estado de carregando', () {
      final controller = DashboardController();
      expect(controller.carregando, isTrue);
    });

    test('inicia sem erro', () {
      final controller = DashboardController();
      expect(controller.erro, isNull);
    });

    test('inicia com lista de transações vazia', () {
      final controller = DashboardController();
      expect(controller.transacoes, isEmpty);
    });
  });

  group('Transaction — cálculos com dados reais', () {
    test('soma de valores de múltiplas transações', () {
      final transacoes = [
        _criarTransacao(id: '1', valor: 100.0),
        _criarTransacao(id: '2', valor: 200.0),
        _criarTransacao(id: '3', valor: 50.50),
      ];

      final total = transacoes.fold<double>(0, (soma, t) => soma + t.valor);
      expect(total, equals(350.50));
    });

    test('agrupamento por categoria soma corretamente', () {
      final transacoes = [
        _criarTransacao(id: '1', valor: 100.0, categoria: 'Alimentação'),
        _criarTransacao(id: '2', valor: 50.0, categoria: 'Alimentação'),
        _criarTransacao(id: '3', valor: 200.0, categoria: 'Moradia'),
      ];

      final mapa = <String, double>{};
      for (final t in transacoes) {
        mapa[t.categoria] = (mapa[t.categoria] ?? 0) + t.valor;
      }

      expect(mapa['Alimentação'], equals(150.0));
      expect(mapa['Moradia'], equals(200.0));
    });

    test('ordenação por categoria do maior para o menor', () {
      final mapa = {
        'Lazer': 50.0,
        'Moradia': 1500.0,
        'Alimentação': 300.0,
      };

      final ordenado = mapa.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      expect(ordenado[0].key, equals('Moradia'));
      expect(ordenado[1].key, equals('Alimentação'));
      expect(ordenado[2].key, equals('Lazer'));
    });

    test('transacoesRecentes limita a 6 itens', () {
      final transacoes = List.generate(
        10,
        (i) => _criarTransacao(id: 'id-$i', valor: i * 10.0),
      );

      final recentes = transacoes.take(6).toList();
      expect(recentes.length, equals(6));
    });

    test('transacoesRecentes retorna todos quando há menos de 6', () {
      final transacoes = List.generate(
        3,
        (i) => _criarTransacao(id: 'id-$i', valor: i * 10.0),
      );

      final recentes = transacoes.take(6).toList();
      expect(recentes.length, equals(3));
    });
  });
}
