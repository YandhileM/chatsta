import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../core/constants/api_constants.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  String? _chatId;
  String? _accessKey;
  bool _isConnecting = false;
  bool _intentionalClose = false;
  Timer? _reconnectionTimer;
  Timer? _heartbeatTimer;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // Connection states
  bool get isConnected => _channel != null;
  bool get isConnecting => _isConnecting;

  // Connection event callbacks
  Function()? onConnect;
  Function()? onDisconnect;
  Function(dynamic)? onError;

  // Chat event callbacks
  Function(Map<String, dynamic>)? onChatCreated;
  Function(Map<String, dynamic>)? onChatUpdated;
  Function(String)? onChatDeleted;

  // Message event callbacks
  Function(Map<String, dynamic>)? onMessageCreated;
  Function(Map<String, dynamic>)? onMessageUpdated;
  Function(String)? onMessageDeleted;
  Function(Map<String, dynamic>)? onMessageRead;

  // User event callbacks
  Function(Map<String, dynamic>)? onUserJoined;
  Function(Map<String, dynamic>)? onUserLeft;
  Function(Map<String, dynamic>)? onUserUpdated;
  Function(String)? onUserTyping;

  Future<void> connectToChat({
    required String chatId,
    required String accessKey,
    // Connection callbacks
    Function()? onConnect,
    Function()? onDisconnect,
    Function(dynamic)? onError,
    // Chat callbacks
    Function(Map<String, dynamic>)? onChatCreated,
    Function(Map<String, dynamic>)? onChatUpdated,
    Function(String)? onChatDeleted,
    // Message callbacks
    Function(Map<String, dynamic>)? onMessageCreated,
    Function(Map<String, dynamic>)? onMessageUpdated,
    Function(String)? onMessageDeleted,
    Function(Map<String, dynamic>)? onMessageRead,
    // User callbacks
    Function(Map<String, dynamic>)? onUserJoined,
    Function(Map<String, dynamic>)? onUserLeft,
    Function(Map<String, dynamic>)? onUserUpdated,
    Function(String)? onUserTyping,
  }) async {
    if (_isConnecting) return;

    _chatId = chatId;
    _accessKey = accessKey;
    _isConnecting = true;
    _intentionalClose = false;

    // Set all callbacks
    this.onConnect = onConnect;
    this.onDisconnect = onDisconnect;
    this.onError = onError;
    this.onChatCreated = onChatCreated;
    this.onChatUpdated = onChatUpdated;
    this.onChatDeleted = onChatDeleted;
    this.onMessageCreated = onMessageCreated;
    this.onMessageUpdated = onMessageUpdated;
    this.onMessageDeleted = onMessageDeleted;
    this.onMessageRead = onMessageRead;
    this.onUserJoined = onUserJoined;
    this.onUserLeft = onUserLeft;
    this.onUserUpdated = onUserUpdated;
    this.onUserTyping = onUserTyping;

    try {
      final wsUrl = Uri.parse(
        'wss://api.chatengine.io/chat/?projectID=${ApiConstants.projectId}&chatID=$chatId&accessKey=$accessKey',
      );

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl.toString()));
      _startHeartbeat();
      _listenToMessages();

      _isConnecting = false;
      onConnect?.call();
    } catch (e) {
      _isConnecting = false;
      onError?.call(e);
      if (!_intentionalClose) {
        _scheduleReconnection();
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        _channel?.sink.add(jsonEncode({
          'action': 'heartbeat',
          'data': {'timestamp': DateTime.now().toIso8601String()}
        }));
      }
    });
  }

  void _listenToMessages() {
    _channel?.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message);
          _handleWebSocketMessage(data);
        } catch (e) {
          onError?.call(e);
        }
      },
      onError: (error) {
        onError?.call(error);
        _handleDisconnection();
      },
      onDone: () {
        _handleDisconnection();
      },
    );
  }

  void _handleDisconnection() {
    _channel = null;
    onDisconnect?.call();
    _scheduleReconnection();
  }

  void _scheduleReconnection() {
    if (_intentionalClose) return;

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(_reconnectDelay, () {
      if (_chatId != null &&
          _accessKey != null &&
          !isConnected &&
          !_isConnecting &&
          !_intentionalClose) {
        connectToChat(
          chatId: _chatId!,
          accessKey: _accessKey!,
          onConnect: onConnect,
          onDisconnect: onDisconnect,
          onError: onError,
          onChatCreated: onChatCreated,
          onChatUpdated: onChatUpdated,
          onChatDeleted: onChatDeleted,
          onMessageCreated: onMessageCreated,
          onMessageUpdated: onMessageUpdated,
          onMessageDeleted: onMessageDeleted,
          onMessageRead: onMessageRead,
          onUserJoined: onUserJoined,
          onUserLeft: onUserLeft,
          onUserUpdated: onUserUpdated,
          onUserTyping: onUserTyping,
        );
      }
    });
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final String action = message['action'] ?? '';
    final data = message['data'];

    switch (action) {
      // Chat events
      case 'chat_created':
        onChatCreated?.call(data);
        break;
      case 'chat_updated':
        onChatUpdated?.call(data);
        break;
      case 'chat_deleted':
        onChatDeleted?.call(data['chat_id'].toString());
        break;

      // Message events
      case 'message_created':
        onMessageCreated?.call(data);
        break;
      case 'message_updated':
        onMessageUpdated?.call(data);
        break;
      case 'message_deleted':
        onMessageDeleted?.call(data['message_id'].toString());
        break;
      case 'message_read':
        onMessageRead?.call(data);
      case 'new_message':
        onMessageCreated?.call(data);
        break;

      // User events
      case 'user_joined':
        onUserJoined?.call(data);
        break;
      case 'user_left':
        onUserLeft?.call(data);
        break;
      case 'user_updated':
        onUserUpdated?.call(data);
        break;
      case 'typing':
        onUserTyping?.call(data['username'].toString());
        break;

      // Handle heartbeat response if needed
      case 'heartbeat':
        // Heartbeat received, connection is alive
        break;

      default:
    }
  }

  // Sending messages
  void sendMessage(String message) {
    if (_channel != null) {
      final data = {
        'action': 'message_created',
        'data': {
          'text': message,
          'chat_id': _chatId,
        },
      };
      _channel!.sink.add(jsonEncode(data));
    }
  }

  // Update message
  void updateMessage(String messageId, String newText) {
    if (_channel != null) {
      final data = {
        'action': 'message_updated',
        'data': {
          'message_id': messageId,
          'text': newText,
        },
      };
      _channel!.sink.add(jsonEncode(data));
    }
  }

  // Delete message
  void deleteMessage(String messageId) {
    if (_channel != null) {
      final data = {
        'action': 'message_deleted',
        'data': {
          'message_id': messageId,
        },
      };
      _channel!.sink.add(jsonEncode(data));
    }
  }

  // Mark message as read
  void markMessageAsRead(String messageId) {
    if (_channel != null) {
      final data = {
        'action': 'message_read',
        'data': {
          'message_id': messageId,
        },
      };
      _channel!.sink.add(jsonEncode(data));
    }
  }

  // Send typing indicator
  void sendTypingEvent() {
    if (_channel != null) {
      final data = {
        'action': 'typing',
        'data': {
          'chat_id': _chatId,
        },
      };
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void close() {
    _intentionalClose = true;
    _reconnectionTimer?.cancel();
    _heartbeatTimer?.cancel();
    try {
      _channel?.sink.close(status.normalClosure);
    } catch (e) {
      // Error intentionally ignored
    } finally {
      _channel = null;
      _chatId = null;
      _accessKey = null;
      _isConnecting = false;
    }
  }


  // Clean up resources
  void dispose() {
    _reconnectionTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _chatId = null;
    _isConnecting = false;
    close();
  }
}
