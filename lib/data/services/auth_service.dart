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
          'Private-Key': privateKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'secret': secret,
          'custom_json': jsonEncode(customJson ?? {}), // Convert to string
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Sign up failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Error during signup: $e');
      print('Stack trace: $stackTrace');
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
          'Project-ID': projectId,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Sign in failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during sign in: $e');
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
          'Project-ID': projectId,
          'User-Name': username,
          'User-Secret': secret,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Get user failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
}
