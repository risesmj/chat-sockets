abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;

  SendMessageEvent(this.message);
}

class RefreshEvent extends ChatEvent {}
