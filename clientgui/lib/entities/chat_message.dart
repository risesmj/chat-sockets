class ChatMessage {
  final String message;
  final String type;

  ChatMessage({
    required this.message,
    this.type = TypeMessage.server,
  });
}

class TypeMessage {
  static const String you = "me";
  static const String server = "server";
}
