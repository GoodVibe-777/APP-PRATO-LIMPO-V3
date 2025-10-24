class ChatMessage {
  ChatMessage({
    required this.id,
    required this.conteudo,
    required this.eDoUsuario,
    required this.data,
  });

  final String id;
  final String conteudo;
  final bool eDoUsuario;
  final DateTime data;
}
