abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;

  SendMessageEvent(this.message);
}

class TypingEvent extends ChatEvent {}

class StopTypingEvent extends ChatEvent {}

class RefreshEvent extends ChatEvent {}

class ScrollToBottomEvent extends ChatEvent {}
