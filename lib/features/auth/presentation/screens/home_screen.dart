import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../data/services/chat_service.dart';
import 'chat_details_screen.dart';
import 'Users/user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatsService _chatService = ChatsService();
  List<dynamic> chats = [];
  String username = '';
  bool isLoading = true;

  Future<void> fetchChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('username') ?? '';
      final secret = prefs.getString('secret') ?? '';

      setState(() {
        username = savedUsername;
      });

      if (savedUsername.isNotEmpty && secret.isNotEmpty) {
        final fetchedChats = await _chatService.getChats(
          username: savedUsername,
          secret: secret,
        );

        setState(() {
          chats = fetchedChats;
          isLoading = false;
        });
      } else {
        print('User credentials are missing in SharedPreferences.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading chats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $username',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
                fontSize: 12,
              ),
            ),
            const Text(
              'Chatsta',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const UsersScreen();
                },
              ));
            },
            icon: const Icon(Icons.add, color: Colors.grey),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
              ? const Center(child: Text('No chats available.'))
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final chatTitle = chat['title'] ?? 'No Title';
                    final admin = chat['admin']['username'];
                    final randomAvatar =
                        'assets/${Random().nextInt(10) + 1}.png';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(randomAvatar),
                      ),
                      title: Text(chatTitle),
                      subtitle: Text('Admin: $admin'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailsScreen(
                              chatId: chat['id']?.toString() ??
                                  '', 
                              chatName: chatTitle,
                            ),
                          ),
                        );

                      },
                    );
                  },
                ),
    );
  }
}
