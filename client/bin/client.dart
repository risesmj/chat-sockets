import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

void main() async {
  // connect to the socket server
  final socket = await Socket.connect('localhost', 4567);
  stdout.writeln(
      'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

  // listen for responses from the server
  socket.listen(
    // handle data from the server
    (Uint8List data) {
      final serverResponse = String.fromCharCodes(data);
      stdout.writeln('Server: $serverResponse');
    },

    // handle errors
    onError: (error) {
      stdout.writeln(error);
      socket.destroy();
    },

    // handle server ending connection
    onDone: () {
      stdout.writeln('Server left.');
      socket.destroy();
    },
  );

  while (true) {
    final line = stdin.readLineSync(encoding: utf8);

    if (line != null && line.isNotEmpty) {
      sendMessage(socket, line);
    }
  }
}

Future<void> sendMessage(Socket socket, String message) async {
  stdout.writeln('Client: $message');
  socket.write(message);
  await Future.delayed(Duration(seconds: 2));
}
