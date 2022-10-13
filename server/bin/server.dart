import 'dart:io';
import 'dart:typed_data';

final list = <Socket>[];
final newMessages = <String>[];

void main() async {
  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);

  // listen for clent connections to the server
  server.listen((client) {
    list.add(client);

    handleConnection(client);
  });
}

void sendMessageAllClient(String message) {
  for (Socket s in list) {
    s.write(message);
  }
}

void handleConnection(Socket client) {
  stdout.writeln('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');

  // listen for events from the client
  client.listen(
    // handle data from the client
    (Uint8List data) async {
      await Future.delayed(Duration(seconds: 1));
      final message = String.fromCharCodes(data);

      for (Socket s in list) {
        await Future.delayed(Duration(seconds: 1));
        s.write(message);
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
