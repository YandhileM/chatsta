import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
import '../../core/constants/api_constants.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  String? _username;
  String? _secret;

  // Updated callback signatures to be more specific
  Function(String chatId, Map<String, dynamic> messageData)? onNewMessage;
  Function(String chatId, String username)? onTyping;
  Function(Map<String, dynamic>)? onChatUpdate;
  Function(String)? onChatDelete;
  Function(Map<String, dynamic>)? onNewChat;
  Function(String chatId, String messageId, String username)? onMessageRead;

  bool get isConnected => _channel != null;

  void connect({
    required String username,
    required String secret,
    Function(String chatId, Map<String, dynamic> messageData)? onNewMessage,
    Function(String chatId, String username)? onTyping,
    Function(Map<String, dynamic>)? onChatUpdate,
    Function(String)? onChatDelete,
    Function(Map<String, dynamic>)? onNewChat,
    Function(String chatId, String messageId, String username)? onMessageRead,
  }) {
    _username = username;
    _secret = secret;
    this.onNewMessage = onNewMessage;
    this.onTyping = onTyping;
    this.onChatUpdate = onChatUpdate;
    this.onChatDelete = onChatDelete;
    this.onNewChat = onNewChat;
    this.onMessageRead = onMessageRead;

    final wsUrl = Uri.parse(
      'wss://api.chatengine.io/person/?publicKey=${ApiConstants.projectId}&username=$username&secret=$secret',
    );

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl.toString()));
    _listenToMessages();
  }

  void _listenToMessages() {
    _channel?.stream.listen(
      (message) {
        final data = jsonDecode(message);
        _handleWebSocketMessage(data);
      },
      onError: (error) {
        _reconnect();
      },
      onDone: () {
        _reconnect();
      },
    );
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final data = message['data'];

    switch (message['action']) {
      case 'new_message':
        final chatId = data['chat_id'].toString();
        onNewMessage?.call(chatId, data);
        break;

      case 'is_typing':
        final chatId = data['chat_id'].toString();
        final username = data['person']['username'] as String;
        onTyping?.call(chatId, username);
        break;

      case 'edit_chat':
        onChatUpdate?.call(data);
        break;

      case 'delete_chat':
        final chatId = data['id'].toString();
        onChatDelete?.call(chatId);
        break;

      case 'add_chat':
        onNewChat?.call(data);
        break;

      case 'read_message':
        final chatId = data['chat_id'].toString();
        final messageId = data['message_id'].toString();
        final username = data['person']['username'] as String;
        onMessageRead?.call(chatId, messageId, username);
        break;

      default:
    }
  }

  void _reconnect() {
    if (_username != null && _secret != null) {
      Future.delayed(const Duration(seconds: 5), () {
        connect(
          username: _username!,
          secret: _secret!,
          onNewMessage: onNewMessage,
          onTyping: onTyping,
          onChatUpdate: onChatUpdate,
          onChatDelete: onChatDelete,
          onNewChat: onNewChat,
          onMessageRead: onMessageRead,
        );
      });
    }
  }

  void disconnect() {
    try {

      _channel?.sink.close(1000);
    } catch (e) {
      // print('Error closing WebSocket connection: $e');
    } finally {
      _channel = null;
      _username = null;
      _secret = null;
    }
  }
}
