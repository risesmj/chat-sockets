import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

final list = <Socket>[];
final newMessages = <String>[];

void main() async {
  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 9998);

  // listen for clent connections to the server
  server.listen((client) {
    list.add(client);

    handleConnection(client);
  });
}

void handleConnection(Socket client) {
  stdout.writeln('Connection from'
      '${client.remoteAddress.address}:${client.remotePort}');

  // listen for events from the client
  client.listen(
    // handle data from the client
    (Uint8List data) async {
      await Future.delayed(Duration(seconds: 1));
      final message = String.fromCharCodes(data);

      final objectTransfer = jsonDecode(message);

      var isNewMessage = false;

      //Evento de nova mensagem, envia a notificação pro cliente que o servidor recebeu a mensagem
      if (objectTransfer['event'] == ChatObjectEvent.newMessage) {
        isNewMessage = true;

        try {
          objectTransfer['event'] = ChatObjectEvent.serverReceived;
          client.write(
            jsonEncode(
              objectTransfer,
            ),
          );
          await Future.delayed(Duration(seconds: 1));
        } catch (_) {}
      }

      //Dispara a mensagem para todos os outros clientes
      final currentClient =
          '${client.remoteAddress.address}:${client.remotePort}';
      for (Socket s in list) {
        try {
          if (currentClient != '${s.remoteAddress.address}:${s.remotePort}') {
            s.write(message);
          }
        } catch (_) {}
      }
      await Future.delayed(Duration(seconds: 1));

      //Envia a notificação de entregue
      if (isNewMessage) {
        try {
          objectTransfer['event'] = ChatObjectEvent.otherUsersReceived;
          client.write(
            jsonEncode(
              objectTransfer,
            ),
          );
        } catch (_) {}
      }
    },

    // handle errors
    onError: (error) {
      stdout.writeln(error);
      client.close();
    },

    // handle the client closing the connection
    onDone: () {
      stdout.writeln('Client left');
      client.close();
    },
  );
}

class ChatObjectEvent {
  static const String typing = "typing";
  static const String stopTyping = "stop_typing";
  static const String newMessage = "new_message";
  static const String serverReceived = "server_received";
  static const String otherUsersReceived = "other_users_received";
  static const String read = "other_users_read";
}
