abstract class ChatState {}

class InitialState extends ChatState {}

class MessageReceivedState extends ChatState {
  final List<String> messages;

  MessageReceivedState(this.messages);
}

class NewMessageState extends ChatState {}
