import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../data/services/chat_service.dart';
import '../../../../../data/services/chat_websocket_service.dart';
import 'chat_details_screen.dart';
import 'Users/user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatsService _chatService = ChatsService();
  final ChatWebSocketService _webSocketService = ChatWebSocketService();
  List<dynamic> chats = [];
  String username = '';
  bool isLoading = true;
  final Map<String, String> typingUsers = {};

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  void _updateChat(Map<String, dynamic> updatedChat) {
    setState(() {
      final index = chats.indexWhere(
          (chat) => chat['id'].toString() == updatedChat['id'].toString());
      if (index != -1) {
        chats[index] = updatedChat;
      }
    });
  }

  void _addChat(Map<String, dynamic> newChat) {
    setState(() {
      chats.insert(0, newChat);
    });
  }

  void _removeChat(String chatId) {
    setState(() {
      chats.removeWhere((chat) => chat['id'].toString() == chatId);
    });
  }

  void _updateTypingStatus(String chatId, String username) {
    setState(() {
      typingUsers[chatId] = username;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (typingUsers[chatId] == username) {
          typingUsers.remove(chatId);
        }
      });
    });
  }

  Future<void> fetchChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('username') ?? '';
      final secret = prefs.getString('secret') ?? '';

      setState(() {
        username = savedUsername;
      });

      if (savedUsername.isNotEmpty && secret.isNotEmpty) {
        _connectWebSocket(savedUsername, secret);

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

  void _connectWebSocket(String username, String secret) {
    _webSocketService.connect(
      username: username,
      secret: secret,
      onNewMessage: (chatId, messageData) {
        final chat = chats.firstWhere(
          (chat) => chat['id'].toString() == chatId,
          orElse: () => null,
        );
        if (chat != null) {
          chat['last_message'] = messageData;
          _updateChat(chat);
        }
      },
      onNewChat: (data) {
        _addChat(data);
      },
      onChatUpdate: (data) {
        _updateChat(data);
      },
      onChatDelete: (chatId) {
        _removeChat(chatId);
      },
      onTyping: (chatId, typingUsername) {
        _updateTypingStatus(chatId, typingUsername);
      },
      onMessageRead: (chatId, messageId, readByUsername) {
        final chat = chats.firstWhere(
          (chat) => chat['id'].toString() == chatId,
          orElse: () => null,
        );
        if (chat != null) {
          _updateChat(chat);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  String _getLastMessageText(dynamic chat) {
    if (chat['last_message'] != null) {
      final sender = chat['last_message']['sender_username'] ?? '';
      final text = chat['last_message']['text'] ?? '';
      return '$sender: $text';
    }
    return 'No messages yet';
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
                    final chatId = chat['id'].toString();
                    final chatTitle = chat['title'] ?? 'No Title';
                    final lastMessage = _getLastMessageText(chat);
                    final randomAvatar =
                        'assets/${Random().nextInt(10) + 1}.png';
                    final isTyping = typingUsers.containsKey(chatId);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(randomAvatar),
                      ),
                      title: Text(
                        chatTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: isTyping
                          ? Text(
                              '${typingUsers[chatId]} is typing...',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailsScreen(
                              chatId: chatId,
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
