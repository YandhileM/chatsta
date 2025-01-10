// lib/data/repositories/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final String baseUrl;
  final String privateKey;
  final String projectId;

  AuthRepository({
    required this.baseUrl,
    required this.privateKey,
    required this.projectId,
  });

  // Sign Up Method
  Future<void> signUp({
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
          'custom_json': customJson ?? {},
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to sign up: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Sign In Method
  Future<void> signIn({
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

      if (response.statusCode != 200) {
        throw Exception('Failed to sign in: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get User Method
  Future<Map<String, dynamic>> getUser({
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
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
