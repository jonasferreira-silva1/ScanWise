import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/transaction.dart';

/// Serviço centralizado para operações no Firebase.
///
/// Encapsula o Firestore e o Auth para que as features não dependam
/// diretamente dos SDKs do Firebase — facilita testes e manutenção.
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Referência à coleção de transações no Firestore.
  CollectionReference<Map<String, dynamic>> get _colecaoTransacoes =>
      _firestore.collection('transactions');

  /// Retorna o ID do usuário autenticado.
  /// Lança [Exception] se não houver usuário logado.
  String get uidAtual {
    final usuario = _auth.currentUser;
    if (usuario == null) throw Exception('Usuário não autenticado.');
    return usuario.uid;
  }

  // ---------------------------------------------------------------------------
  // Transações
  // ---------------------------------------------------------------------------

  /// Salva uma transação no Firestore.
  Future<void> salvarTransacao(Transaction transacao) async {
    await _colecaoTransacoes
        .doc(transacao.id)
        .set(transacao.toMap());
  }

  /// Remove uma transação pelo ID.
  Future<void> deletarTransacao(String id) async {
    await _colecaoTransacoes.doc(id).delete();
  }

  /// Busca todas as transações do usuário em um intervalo de datas.
  ///
  /// Retorna lista ordenada da mais recente para a mais antiga.
  Future<List<Transaction>> buscarTransacoes({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final snapshot = await _colecaoTransacoes
        .where('uid', isEqualTo: uidAtual)
        .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('data', isLessThanOrEqualTo: fim.toIso8601String())
        .orderBy('data', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data()))
        .toList();
  }

  /// Busca as transações do mês atual.
  Future<List<Transaction>> buscarTransacoesMesAtual() async {
    final agora = DateTime.now();
    final inicioMes = DateTime(agora.year, agora.month, 1);
    final fimMes = DateTime(agora.year, agora.month + 1, 0, 23, 59, 59);

    return buscarTransacoes(inicio: inicioMes, fim: fimMes);
  }

  /// Retorna um Stream das transações do mês atual para atualização em tempo real.
  Stream<List<Transaction>> streamTransacoesMesAtual() {
    final agora = DateTime.now();
    final inicioMes = DateTime(agora.year, agora.month, 1);

    return _colecaoTransacoes
        .where('uid', isEqualTo: uidAtual)
        .where('data', isGreaterThanOrEqualTo: inicioMes.toIso8601String())
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Transaction.fromMap(doc.data()))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Resumo financeiro (usado como contexto no chat)
  // ---------------------------------------------------------------------------

  /// Gera um resumo textual dos gastos do mês para injetar no prompt do Claude.
  ///
  /// Exemplo de retorno:
  /// "Total gasto: R$ 1.250,00\n\nPor categoria:\n- Alimentação: R$ 450,00"
  Future<String> gerarContextoFinanceiro() async {
    final transacoes = await buscarTransacoesMesAtual();

    if (transacoes.isEmpty) {
      return 'Nenhum gasto registrado este mês ainda.';
    }

    // Agrupa valores por categoria
    final porCategoria = <String, double>{};
    double total = 0;

    for (final t in transacoes) {
      porCategoria[t.categoria] = (porCategoria[t.categoria] ?? 0) + t.valor;
      total += t.valor;
    }

    // Ordena do maior para o menor gasto
    final categoriaOrdenada = porCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final linhas = categoriaOrdenada
        .map((e) => '- ${e.key}: R\$ ${e.value.toStringAsFixed(2)}')
        .join('\n');

    return 'Total gasto este mês: R\$ ${total.toStringAsFixed(2)}\n\n'
        'Por categoria:\n$linhas';
  }
}
