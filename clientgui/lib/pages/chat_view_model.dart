import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clientgui/entities/chat_message.dart';
import 'package:clientgui/entities/chat_object_transfer.dart';
import 'package:clientgui/pages/chat_event.dart';
import 'package:clientgui/pages/chat_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:uuid/uuid.dart';

class ChatViewModel extends Bloc<ChatEvent, ChatState> {
  final messages = RxNotifier<List<ChatMessage>>(
    [],
  );

  final userTyping = RxNotifier<String>("");
  final ctrlTextController = TextEditingController();
  final ScrollController ctrlScrollMessages = ScrollController();
  String userName = "guest";

  Socket? socket;

  bool isTyping = false;

  ChatViewModel() : super(InitialState()) {
    on<SendMessageEvent>(_handlerSendMessageEvent);
    on<RefreshEvent>(_handlerRefreshEvent);
    on<TypingEvent>(_handlerTypingEvent);
    on<StopTypingEvent>(_handlerStopTypingEvent);
  }

  initSocket() async {
    // connect to the socket server
    socket = await Socket.connect('10.3.2.92', 9998);
    print(
        'Connected to: ${socket?.remoteAddress.address}:${socket?.remotePort}');

    // listen for responses from the server
    socket?.listen(
      // handle data from the server
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        final objectTransfer = ChatObjectTransfer.fromJson(serverResponse);

        switch (objectTransfer.event) {
          case ChatObjectEvent.serverReceived:
            _handlerMessageSended(objectTransfer.id);
            break;

          case ChatObjectEvent.otherUsersReceived:
            _handlerMessageDelivered(objectTransfer.id);
            break;

          case ChatObjectEvent.newMessage:
            _handlerNewMessage(objectTransfer);
            break;

          case ChatObjectEvent.read:
            _handlerMessageRead(objectTransfer.id);
            break;

          case ChatObjectEvent.typing:
            _handlerUserTyping(objectTransfer);
            break;

          case ChatObjectEvent.stopTyping:
            _handlerUserStopTyping(objectTransfer);
            break;
        }

        add(RefreshEvent());
      },

      // handle errors
      onError: (error) {
        socket?.destroy();
      },

      // handle server ending connection
      onDone: () {
        messages.value.add(
          ChatMessage(
            message: "Servidor desconectado.",
            type: TypeMessage.server,
          ),
        );
        add(RefreshEvent());
        socket?.destroy();
      },
    );
  }

  //--------------------- EVENTS BLOC ---------------------

  _handlerRefreshEvent(RefreshEvent event, emit) {
    emit(NewMessageState());
  }

  _handlerSendMessageEvent(SendMessageEvent event, emit) async {
    if (event.message.isNotEmpty) {
      final objectTransfer = ChatObjectTransfer(
        id: const Uuid().v4().toString(),
        event: ChatObjectEvent.newMessage,
        user: userName,
        date: _getDate(),
        content: event.message,
      );

      socket?.write(jsonEncode(objectTransfer.toJson()));
      ctrlTextController.clear();
      messages.value.add(
        ChatMessage(
          id: objectTransfer.id,
          message: "${objectTransfer.date} disse: ${objectTransfer.content}",
          type: TypeMessage.you,
        ),
      );

      add(RefreshEvent());

      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        add(ScrollToBottomEvent());
      });
    }
  }

  _handlerTypingEvent(TypingEvent event, emit) {
    if (!isTyping) {
      isTyping = true;
      final objectTransfer = ChatObjectTransfer(
        id: const Uuid().v4().toString(),
        event: ChatObjectEvent.typing,
        user: userName,
        date: _getDate(),
        content: "",
      );

      socket?.write(jsonEncode(objectTransfer.toJson()));
    }
  }

  _handlerStopTypingEvent(StopTypingEvent event, emit) {
    if (isTyping) {
      isTyping = false;
      final objectTransfer = ChatObjectTransfer(
        id: const Uuid().v4().toString(),
        event: ChatObjectEvent.stopTyping,
        user: userName,
        date: _getDate(),
        content: "",
      );

      socket?.write(jsonEncode(objectTransfer.toJson()));
    }
  }

  //--------------------- HANDLER AND UTIL  ---------------------

  String _getDate() {
    final date = DateTime.now().toString();

    final local = DateTime.parse(date).toLocal();

    final day = local.day.toString().length == 1
        ? "0${local.day.toString()}"
        : local.day.toString();
    final month = local.month.toString().length == 1
        ? "0${local.month.toString()}"
        : local.month.toString();

    String formatted = "$day/$month/${local.year}";

    formatted = "$formatted ${local.hour}h${local.minute}m";

    return formatted;
  }

  _handlerNewMessage(ChatObjectTransfer objectTransfer) {
    final message =
        "${objectTransfer.user} ${objectTransfer.date} disse: ${objectTransfer.content}";

    messages.value.add(
      ChatMessage(
        id: objectTransfer.id,
        message: message,
        type: TypeMessage.server,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      add(ScrollToBottomEvent());
    });

    //Notifica que foi lido
    objectTransfer.event = ChatObjectEvent.read;
    socket?.write(jsonEncode(objectTransfer.toJson()));
  }

  _handlerMessageSended(String id) {
    final index = messages.value.indexWhere((element) => element.id == id);

    if (index > -1) {
      messages.value[index].received = true;
    }
  }

  _handlerMessageDelivered(String id) {
    final index = messages.value.indexWhere((element) => element.id == id);

    if (index > -1) {
      messages.value[index].delivered = true;
    }
  }

  _handlerMessageRead(String id) {
    final index = messages.value.indexWhere((element) => element.id == id);

    if (index > -1) {
      messages.value[index].read = true;
    }
  }

  _handlerUserTyping(ChatObjectTransfer objectTransfer) {
    userTyping.value = "${objectTransfer.user} está digitando...";
  }

  _handlerUserStopTyping(ChatObjectTransfer objectTransfer) {
    userTyping.value = "";
  }
}
