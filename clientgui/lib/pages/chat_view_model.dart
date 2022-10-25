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

class ChatViewModel extends Bloc<ChatEvent, ChatState> {
  final messages = RxNotifier<List<ChatMessage>>(
    [],
  );
  final ctrlTextController = TextEditingController();
  String userName = "guest";

  Socket? socket;

  ChatViewModel() : super(InitialState()) {
    on<SendMessageEvent>(_handlerSendMessageEvent);
    on<RefreshEvent>(_handlerRefreshEvent);
  }

  initSocket() async {
    // connect to the socket server
    socket = await Socket.connect('10.3.2.92', 9999);
    print(
        'Connected to: ${socket?.remoteAddress.address}:${socket?.remotePort}');

    // listen for responses from the server
    socket?.listen(
      // handle data from the server
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        final objectTransfer = ChatObjectTransfer.fromJson(serverResponse);
        final message =
            "${objectTransfer.user} ${objectTransfer.date} disse: ${objectTransfer.content}";

        messages.value.add(
          ChatMessage(
            message: message,
            type: TypeMessage.server,
          ),
        );
        add(RefreshEvent());
      },

      // handle errors
      onError: (error) {
        print(error);
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

  _handlerRefreshEvent(RefreshEvent event, emit) {
    emit(NewMessageState());
  }

  _handlerSendMessageEvent(SendMessageEvent event, emit) async {
    if (event.message.isNotEmpty) {
      final objectTransfer = ChatObjectTransfer(
        event: ChatObjectEvent.newMessage,
        user: userName,
        date: _getDate(),
        content: event.message,
      );

      socket?.write(jsonEncode(objectTransfer.toJson()));
      ctrlTextController.clear();
      messages.value.add(
        ChatMessage(
          message:
              "${objectTransfer.user} ${objectTransfer.date} disse: ${objectTransfer.content}",
          type: TypeMessage.you,
        ),
      );
      add(RefreshEvent());
    }
  }

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
}
