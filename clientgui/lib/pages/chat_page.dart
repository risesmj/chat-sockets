import 'package:clientgui/entities/chat_message.dart';
import 'package:clientgui/pages/chat_event.dart';
import 'package:clientgui/pages/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_triple/flutter_triple.dart';

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
  void initState() {
    super.initState();
    widget.viewModel.on<ScrollToBottomEvent>((ScrollToBottomEvent event, emit) {
      widget.viewModel.ctrlScrollMessages
          .jumpTo(widget.viewModel.ctrlScrollMessages.position.maxScrollExtent);

      setState(() {});
    });
  }

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RxBuilder(
                  builder: ((context) => Text(
                        widget.viewModel.userTyping.value,
                      )),
                ),
              ),
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
        controller: widget.viewModel.ctrlScrollMessages,
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
    var status = "Não enviado";
    if (chatMessage.received) {
      status = "Recebido";
    }

    if (chatMessage.delivered || chatMessage.read) {
      status = "Entregue";
    }

    if (chatMessage.read) {
      status = "Lido";
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
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
            if (chatMessage.type == TypeMessage.you)
              Text(
                status,
                style: TextStyle(
                  color: chatMessage.read ? Colors.purple : Colors.green,
                ),
              ),
          ],
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
          onChanged: (s) {
            widget.viewModel.add(TypingEvent());
          },
          onFieldSubmitted: (value) {
            widget.viewModel.add(SendMessageEvent(value));
          },
          onEditingComplete: () {
            widget.viewModel.add(StopTypingEvent());
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
