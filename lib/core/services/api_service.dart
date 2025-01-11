// import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';

class ApiService {
  static String baseUrl = dotenv.env['CHAT_ENGINE_BASE_URL'] ?? '';
  static String privateKey = dotenv.env['CHAT_ENGINE_PRIVATE_KEY'] ?? '';
  static String projectId = dotenv.env['CHAT_ENGINE_PROJECT_ID'] ?? '';

  static Map<String, String> getHeaders({
    String? projectId,
    String? userName,
    String? secret,
  }) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (privateKey.isNotEmpty) headers['PRIVATE-KEY'] = privateKey;
    if (projectId != null) headers['Project-ID'] = projectId;
    if (userName != null) headers['User-Name'] = userName;
    if (secret != null) headers['User-Secret'] = secret;

    return headers;
  }
}
