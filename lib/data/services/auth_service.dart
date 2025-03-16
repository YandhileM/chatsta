// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthService {
  final String baseUrl = ApiConstants.baseUrl;
  final String privateKey = ApiConstants.privateKey;
  final String projectId = ApiConstants.projectId;


// lib/services/auth_service.dart
  Future<bool> signUp({
    required String username,
    required String firstName,
    required String lastName,
    required String secret,
    Map<String, dynamic>? customJson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {
          'Project-ID': privateKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'FirstName': firstName,
          'LastName': lastName,
          'secret': secret,
          'custom_json': jsonEncode(customJson ?? {}), 
        }),
      );
      print('Sign-up response status code: ${response.statusCode}');
      print('Sign-up response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn({
    required String username,
    required String secret,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

          print('Sign-in response status code: ${response.statusCode}');
      print('Sign-in response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  Future<Map<String, dynamic>?> getUser({
    required String username,
    required String secret,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me/'),
        headers: {
          'Project-ID': privateKey,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
