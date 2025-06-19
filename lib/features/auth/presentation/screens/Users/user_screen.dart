import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../data/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../chat_details_screen.dart';
import '../../../../../data/services/chat_service.dart';

// Chat Name Dialog Widget
class ChatNameDialog extends StatefulWidget {
  final String defaultName;

  const ChatNameDialog({
    super.key,
    required this.defaultName,
  });

  @override
  State<ChatNameDialog> createState() => _ChatNameDialogState();
}

class _ChatNameDialogState extends State<ChatNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Name your chat'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: "Enter chat name",
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// Main Users Screen
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _userService = UserService();
  final ChatsService _chatService = ChatsService();
  late Future<List<Map<String, dynamic>>> _futureUsers;
  final Random _random = Random();

@override
void initState() {
  super.initState();
  // Delay the API calls until after the widget is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      _futureUsers = _fetchFilteredUsers();
    });
  });
}

Future<List<Map<String, dynamic>>> _fetchFilteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUsername = prefs.getString('username');
      final secret = prefs.getString('secret');

      if (currentUsername == null || secret == null) {
        throw Exception('User credentials not found');
      }

      // Run both API calls in parallel for better performance
      final futures = await Future.wait([
        _userService.fetchUsers(currentUsername, secret),
        _chatService.fetchChats(username: currentUsername, secret: secret),
      ]);

      // Cast the first result to the correct type
      final allUsers = (futures[0] as List).cast<Map<String, dynamic>>();
      final existingChats = futures[1];

      // Extract usernames of users already in chats
      final usernamesInChats = existingChats
              ?.expand((chat) => (chat['people'] as List<dynamic>)
                  .map((person) => person['person']['username']))
              .toSet() ??
          {};

      // Filter users: Exclude logged-in user and already-added users
      return allUsers
          .where((user) =>
              user['username'] != currentUsername &&
              !usernamesInChats.contains(user['username']))
          .toList();
    } catch (e) {
      print('Error fetching users: $e'); // Add logging
      return []; // Return empty list on error
    }
  }

  String getRandomAsset() {
    int assetNumber = _random.nextInt(20) + 1;
    return 'assets/$assetNumber.png';
  }

 Future<void> _createChat(Map<String, dynamic> selectedUser) async {
    // Show dialog to get chat name
    final String? chatName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return ChatNameDialog(
          defaultName:
              "Chat with ${selectedUser['first_name']} ${selectedUser['last_name']}",
        );
      },
    );

    // If user cancels, return early
    if (chatName == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUsername = prefs.getString('username');
      final secret = prefs.getString('secret');

      if (currentUsername == null || secret == null) {
        throw Exception('User credentials not found');
      }

      // Use getOrCreateChat instead of createChat
      final response = await _chatService.getOrCreateChat(
        username: currentUsername,
        secret: secret,
        usernames: [selectedUser['username']],
        title: chatName,
        isDirectChat: true,
      );

      if (response != null && response['id'] != null) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailsScreen(
              chatId: response['id'].toString(),
              chatName: chatName,
              accessKey: response['access_key'], 
            ),
          ),
        );
      } else {
        throw Exception('Failed to create chat: Invalid response');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
                fontSize: 12,
              ),
            ),
            Text(
              'Chatsta',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.edit_square,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final asset = getRandomAsset();

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () {},
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(asset),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            '${user['firstName']} ${user['lastName']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(user['username']),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _createChat(user),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No users found.'));
          }
        },
      ),
    );
  }
}
