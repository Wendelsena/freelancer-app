import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String freelancerId;

  const ChatScreen({super.key, required this.freelancerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(
        child: Text('Chat com o prestador ID: $freelancerId'),
      ),
    );
  }
}