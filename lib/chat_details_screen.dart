import 'package:flutter/material.dart';

class ChatDetailsScreen extends StatefulWidget {
  final int index;
  final String name;
  const ChatDetailsScreen(this.index, this.name, {super.key});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
