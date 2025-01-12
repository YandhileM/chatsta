import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/chat_service.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class ChatDetailsScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final ChatsService _chatService = ChatsService();
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  String message = "";
  bool isLoading = true;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    fetchChatMessages();
    _getCurrentUsername();
  }

  String formatDateTime(String dateTimeString) {
    try {
      // Parse the UTC datetime string
      DateTime dateTime = DateTime.parse(dateTimeString);

      // Format the date and time
      return DateFormat('yyyy/MM/dd HH:mm').format(dateTime.toLocal());
    } catch (e) {
      print('Error formatting date: $e');
      return dateTimeString; // Return original string if parsing fails
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
      } else {
        print('User credentials are missing in SharedPreferences.');
      }
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        isLoading = false;
      });
    }
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
                        : Container(
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () async {
                                if (message.isNotEmpty) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final username = prefs.getString('username')!;
                                  final secret = prefs.getString('secret')!;

                                  final success =
                                      await _chatService.sendMessage(
                                    username: username,
                                    secret: secret,
                                    chatId: widget.chatId,
                                    messageText: message,
                                  );

                                  if (success) {
                                    setState(() {
                                      messages.add({
                                        'text': message,
                                        'sender_username': currentUsername,
                                        'created':
                                            DateTime.now().toUtc().toString(),
                                      });
                                      _controller.clear();
                                      message = '';
                                    });
                                  } else {
                                    print('Failed to send the message.');
                                  }
                                }
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(CupertinoIcons.arrow_up,
                                    color: Colors.white),
                              ),
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
