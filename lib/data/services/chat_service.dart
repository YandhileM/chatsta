// lib/services/chats_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ChatsService {
  final String baseUrl = ApiConstants.baseUrl;
  // final String projectId = ApiConstants.projectId;
    final String privateKey = ApiConstants.privateKey;

  /// Fetches the list of chats for the authenticated user.
  Future<List<dynamic>?> fetchChats({
    required String username,
    required String secret,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  Future<List<dynamic>> getChats({
    required String username,
    required String secret,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Fetches the details of a specific chat by its ID.
  Future<Map<String, dynamic>?> fetchChatDetails({
    required String username,
    required String secret,
    required int chatId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Sends a message to a specific chat.
  // Future<bool> sendMessage({
  //   required String username,
  //   required String secret,
  //   required int chatId,
  //   required String messageText,
  //   List<Map<String, dynamic>>? attachments,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/chats/$chatId/messages/'),
  //       headers: {
  //         'Project-ID': privateKey,
  //         'User-Name': username,
  //         'User-Secret': secret,
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'text': messageText,
  //         'attachments': attachments ?? [],
  //       }),
  //     );

  //     if (response.statusCode == 201) {
  //       return true;
  //     } else {
  //       print('Send message failed with status code: ${response.statusCode}');
  //       print('Response body: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error sending message: $e');
  //     return false;
  //   }
  // }
   Future<List<Map<String, dynamic>>> getChatMessages({
    required String chatId,
    required String username,
    required String secret,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId/messages/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
   /// Creates a new chat with the specified parameters.
  Future<Map<String, dynamic>?> createChat({
    required String username,
    required String secret,
    required List<String> usernames,
    required String title,
    bool isDirectChat = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chats/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'usernames': usernames,
          'title': title,
          'is_direct_chat': isDirectChat,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  /// Sends a text message to a specific chat.
Future<bool> sendMessage({
  required String username,
  required String secret,
  required String chatId,
  required String messageText,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/chats/$chatId/messages/'),
      headers: {
        'Project-ID': privateKey,
        'User-Name': username,
        'User-Secret': secret,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': messageText,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

/// Fetches the latest `chatCount` messages from the chat with the specified `chatId`.
  Future<List<Map<String, dynamic>>> fetchLatestMessages({
    required String chatId,
    required String username,
    required String secret,
    required int chatCount,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId/messages/latest/$chatCount/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  Future<Map<String, dynamic>?> getOrCreateChat({
    required String username,
    required String secret,
    required List<String> usernames,
    required String title,
    bool isDirectChat = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chats/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'usernames': usernames,
          'title': title,
          'is_direct_chat': isDirectChat,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
