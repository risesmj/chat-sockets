import 'package:flutter/material.dart';
import 'pages/chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Socket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}
