/// Representa uma mensagem na conversa do chat financeiro.
///
/// Usada tanto para mensagens do usuário quanto para respostas do assistente.
class ChatMessage {
  final String texto;

  /// true = mensagem do usuário, false = resposta do assistente (FinZen)
  final bool isUser;

  /// Momento em que a mensagem foi criada — usado para ordenação
  final DateTime timestamp;

  ChatMessage({
    required this.texto,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'ChatMessage(isUser: $isUser, texto: ${texto.substring(0, texto.length.clamp(0, 50))}...)';
}
