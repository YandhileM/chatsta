import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/chat_service.dart';
// import '../../../../data/services/chat_websocket_service.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/chat_room_websocket_service.dart';
// import '../../../../data/services/chat_websocket_service.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String accessKey;

  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.accessKey,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final ChatsService _chatService = ChatsService();
  final ChatWebSocketService _wsService = ChatWebSocketService();
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  String message = "";
  bool isLoading = true;
  String? currentUsername;
  Set<String> typingUsers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentUsername();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await fetchChatMessages();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _wsService.connectToChat(
      chatId: widget.chatId,
      accessKey: widget.accessKey,

      // Connection events
      onConnect: () {
      },
      onDisconnect: () {
      },
      onError: (error) {
      },

      // Chat events
      onChatUpdated: (data) {
        setState(() {
          // Update chat name or other details if needed
        });
      },
      onChatDeleted: (chatId) {
        Navigator.of(context).pop();
      },

      // Message events
      onMessageCreated: (data) {
        if (mounted) {
          setState(() {
            final messageData = data['message'] as Map<String, dynamic>;
            messages.add({
              'id': messageData['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              'text': messageData['text'] ?? '',
              'sender_username': messageData['sender_username'] ??
                  messageData['sender']?['username'] ??
                  'Unknown',
              'created':
                  messageData['created'] ?? DateTime.now().toUtc().toString(),
            });
          });
        }
      },


      onMessageUpdated: (data) {
        setState(() {
          final index =
              messages.indexWhere((m) => m['id'] == data['message_id']);
          if (index != -1) {
            messages[index] = {...messages[index], ...data};
          }
        });
      },
      onMessageDeleted: (messageId) {
        setState(() {
          messages.removeWhere((m) => m['id'] == messageId);
        });
      },
      onMessageRead: (data) {
        setState(() {
          final messageId = data['message_id'];
          final index = messages.indexWhere((m) => m['id'] == messageId);
          if (index != -1) {
            messages[index] = {...messages[index], 'read': true};
          }
        });
      },

      // User events
      onUserJoined: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${data['username']} joined the chat"),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onUserLeft: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${data['username']} left the chat"),
            duration: const Duration(seconds: 2),
          ),
        );
      },
onUserTyping: (username) {
        if (username != currentUsername && mounted) {
          setState(() {
            typingUsers.add(username);
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                typingUsers.remove(username);
              });
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _wsService.close(); 
    _controller.dispose();
    super.dispose();
  }
String formatDateTime(String dateTimeString) {
    try {
      // Handle the timestamp format that includes timezone offset
      // Example input: "2025-01-15 19:18:48.811370+00:00"
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy/MM/dd HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return 'Unknown Date';
    }
  }


  Future<void> _getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username');
    });
  }

  Future<void> fetchChatMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final secret = prefs.getString('secret');

      if (username != null && secret != null) {
        final fetchedMessages = await _chatService.getChatMessages(
          chatId: widget.chatId,
          username: username,
          secret: secret,
        );

        setState(() {
          messages = fetchedMessages;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTypingIndicator() {
    if (typingUsers.isEmpty) return const SizedBox.shrink();

    final typingText = typingUsers.length == 1
        ? "${typingUsers.first} is typing..."
        : "${typingUsers.length} people are typing...";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        typingText,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            CupertinoIcons.chevron_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          widget.chatName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, int i) {
                      final message = messages[i];
                      final isSentByUser =
                          message['sender_username'] == currentUsername;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: isSentByUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isSentByUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSentByUser ? Colors.blue : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    message['text'] ?? '',
                                    textAlign: isSentByUser
                                        ? TextAlign.end
                                        : TextAlign.start,
                                    style: TextStyle(
                                      color: isSentByUser
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  formatDateTime(message['created'] ?? ''),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildTypingIndicator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.paperclip),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          setState(() {
                            message = value;
                          });
                          _wsService.sendTypingEvent();
                        },
                        decoration: const InputDecoration(
                          hintText: "Type message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    message.isEmpty
                        ? const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child:
                                Icon(CupertinoIcons.mic, color: Colors.white),
                          )
                        : GestureDetector(
                            onTap: () async {
                              if (message.isNotEmpty) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final username = prefs.getString('username')!;
                                final secret = prefs.getString('secret')!;

                                final success = await _chatService.sendMessage(
                                  username: username,
                                  secret: secret,
                                  chatId: widget.chatId,
                                  messageText: message,
                                );

                                if (success) {
                                  setState(() {
                                    // messages.add({
                                    //   'id': DateTime.now()
                                    //       .millisecondsSinceEpoch
                                    //       .toString(),
                                    //   'text': message,
                                    //   'sender_username': currentUsername,
                                    //   'created':
                                    //       DateTime.now().toUtc().toString(),
                                    // });
                                    _controller.clear();
                                    message = '';
                                  });
                                } else {
                                }
                              }
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(CupertinoIcons.arrow_up,
                                  color: Colors.white),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
