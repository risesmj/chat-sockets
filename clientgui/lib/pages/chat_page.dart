import 'package:clientgui/entities/chat_message.dart';
import 'package:clientgui/pages/chat_event.dart';
import 'package:clientgui/pages/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  final ChatViewModel viewModel = ChatViewModel();

  ChatPage({Key? key}) : super(key: key) {
    viewModel.initSocket();
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Socket"),
        actions: [
          TextButton(
            onPressed: () {
              showDialogName();
            },
            child: const Text(
              "Informar nome",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              BlocBuilder(
                bloc: widget.viewModel,
                builder: _buildBloc,
              ),
              _buildFieldText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBloc(BuildContext context, state) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.viewModel.messages.value.length,
        shrinkWrap: true,
        itemBuilder: (ctx, index) => ListTile(
          title: _buildItemMessage(
            widget.viewModel.messages.value[index],
          ),
        ),
      ),
    );
  }

  Widget _buildItemMessage(ChatMessage chatMessage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: chatMessage.type == TypeMessage.you
            ? Text(
                "Você: ${chatMessage.message}",
                style: const TextStyle(
                  color: Colors.blue,
                ),
              )
            : Text(
                chatMessage.message,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
      ),
    );
  }

  Widget _buildFieldText() {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(16),
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
        child: TextFormField(
          controller: widget.viewModel.ctrlTextController,
          onFieldSubmitted: (value) {
            widget.viewModel.add(SendMessageEvent(value));
          },
          style: const TextStyle(color: Colors.grey),
          cursorColor: Colors.grey[300],
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.all(10),
            hintStyle: const TextStyle(color: Colors.grey),
            hintText: "Escrever mensagem",
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  showDialogName() {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          color: Colors.blue,
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: TextFormField(
              initialValue: widget.viewModel.userName,
              onChanged: (s) {
                widget.viewModel.userName = s;
              },
              onFieldSubmitted: (s) {
                Navigator.pop(context);
              },
              style: const TextStyle(color: Colors.grey),
              cursorColor: Colors.grey[300],
              decoration: InputDecoration(
                filled: true,
                contentPadding: const EdgeInsets.all(10),
                hintStyle: const TextStyle(color: Colors.grey),
                hintText: "Escrever mensagem",
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
