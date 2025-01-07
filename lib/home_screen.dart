import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Column(children: [
          Text(
            'Hello Yandhile',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
          ),
          Text(
            'Chatsta message',
            style: TextStyle(
              color: Colors.black,
            ),
          )
        ]),
      ),
    );
  }
}
