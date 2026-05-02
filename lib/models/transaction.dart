/// Representa uma transação financeira do usuário.
///
/// Criada a partir do scan de um comprovante (via OCR + Claude)
/// ou manualmente pelo usuário. Persistida no Firestore.
class Transaction {
  final String id;
  final double valor;
  final String descricao;
  final String categoria;
  final DateTime data;

  /// ID do usuário Firebase — garante isolamento de dados no Firestore
  final String uid;

  const Transaction({
    required this.id,
    required this.valor,
    required this.descricao,
    required this.categoria,
    required this.data,
    required this.uid,
  });

  /// Converte para Map para salvar no Firestore.
  Map<String, dynamic> toMap() => {
        'id': id,
        'valor': valor,
        'descricao': descricao,
        'categoria': categoria,
        // Armazena como ISO 8601 para facilitar queries de intervalo de datas
        'data': data.toIso8601String(),
        'uid': uid,
      };

  /// Cria uma Transaction a partir de um documento do Firestore.
  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as String,
        valor: (map['valor'] as num).toDouble(),
        descricao: map['descricao'] as String,
        categoria: map['categoria'] as String,
        data: DateTime.parse(map['data'] as String),
        uid: map['uid'] as String,
      );

  /// Cria uma cópia com campos alterados — útil para edição.
  Transaction copyWith({
    String? id,
    double? valor,
    String? descricao,
    String? categoria,
    DateTime? data,
    String? uid,
  }) =>
      Transaction(
        id: id ?? this.id,
        valor: valor ?? this.valor,
        descricao: descricao ?? this.descricao,
        categoria: categoria ?? this.categoria,
        data: data ?? this.data,
        uid: uid ?? this.uid,
      );

  @override
  String toString() =>
      'Transaction(id: $id, valor: $valor, descricao: $descricao, '
      'categoria: $categoria, data: $data)';
}
