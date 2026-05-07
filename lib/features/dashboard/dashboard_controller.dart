import 'package:flutter/material.dart';
import '../../core/services/firebase_service.dart';
import '../../models/transaction.dart';

/// Gerencia os dados financeiros exibidos no Dashboard.
///
/// Usa um Stream do Firestore para atualização em tempo real —
/// quando o usuário salva um gasto pelo Scan, o Dashboard atualiza
/// automaticamente sem precisar recarregar.
class DashboardController extends ChangeNotifier {
  final _firebase = FirebaseService();

  List<Transaction> _transacoes = [];
  List<Transaction> get transacoes => _transacoes;

  bool _carregando = true;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  // Guarda a subscription do stream para cancelar no dispose
  Stream<List<Transaction>>? _stream;

  // ---------------------------------------------------------------------------
  // Inicialização
  // ---------------------------------------------------------------------------

  /// Inicia a escuta em tempo real das transações do mês atual.
  /// Deve ser chamado uma vez, quando o Dashboard é montado.
  void iniciar() {
    try {
      _stream = _firebase.streamTransacoesMesAtual();
      _stream!.listen(
        (transacoes) {
          _transacoes = transacoes;
          _carregando = false;
          _erro = null;
          notifyListeners();
        },
        onError: (e) {
          _erro = 'Erro ao carregar transações. Verifique sua conexão.';
          _carregando = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _erro = 'Erro ao iniciar. Tente reiniciar o app.';
      _carregando = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Cálculos financeiros
  // ---------------------------------------------------------------------------

  /// Total de despesas do mês.
  double get totalDespesas => _transacoes
      .where((t) => t.valor > 0)
      .fold(0, (soma, t) => soma + t.valor);

  /// Número de transações no mês.
  int get totalTransacoes => _transacoes.length;

  /// Agrupa transações por categoria e retorna totais ordenados (maior → menor).
  List<MapEntry<String, double>> get totaisPorCategoria {
    final mapa = <String, double>{};
    for (final t in _transacoes) {
      mapa[t.categoria] = (mapa[t.categoria] ?? 0) + t.valor;
    }
    return mapa.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Retorna as 6 transações mais recentes para a lista do Dashboard.
  List<Transaction> get transacoesRecentes => _transacoes.take(6).toList();

  /// Formata um valor como moeda brasileira: R$ 1.234,56
  static String formatarMoeda(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }
}
