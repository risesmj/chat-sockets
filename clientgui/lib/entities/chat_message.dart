import 'package:uuid/uuid.dart';

class ChatMessage {
  String id;
  final String message;
  final String type;
  bool received;
  bool delivered;
  bool read;

  ChatMessage({
    required this.message,
    this.id = "",
    this.type = TypeMessage.server,
    this.received = false,
    this.delivered = false,
    this.read = false,
  });
}

class TypeMessage {
  static const String you = "me";
  static const String server = "server";
}
