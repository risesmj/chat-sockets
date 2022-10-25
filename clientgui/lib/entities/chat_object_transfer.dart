import 'dart:convert';

class ChatObjectTransfer {
  String event;
  String user;
  String date;
  String content;

  ChatObjectTransfer({
    this.event = ChatObjectEvent.newMessage,
    this.user = "",
    this.date = "",
    this.content = "",
  });

  toJson() {
    final data = <String, dynamic>{};
    data['event'] = event;
    data['user'] = user;
    data['date'] = date;
    data['content'] = content;
    return data;
  }

  factory ChatObjectTransfer.fromJson(String json) {
    final map = jsonDecode(json);
    return ChatObjectTransfer(
      event: map['event'],
      user: map['user'],
      date: map['date'],
      content: map['content'],
    );
  }
}

class ChatObjectEvent {
  static const String typing = "typing";
  static const String newMessage = "new_message";
  static const String serverReceived = "server_received";
  static const String otherUsersReceived = "other_users_received";
  static const String read = "other_users_read";
}
