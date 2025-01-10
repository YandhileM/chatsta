// lib/features/auth/data/repositories/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/user_model.dart';
import '../../../../core/constants/api_constants.dart';

class AuthRepository {
  Future<UserModel> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/me'),
        headers: {
          'Project-ID': ApiConstants.projectId,
          'User-Name': username,
          'User-Secret': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to sign in');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<void> signUp({
    required String username,
    required String firstName,
    required String lastName,
    required String secret,
    Map<String, dynamic>? customJson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/'),
        headers: {
          'Private-Key': ApiConstants.privateKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'secret': secret,
          'custom_json': customJson ?? {"": ""},
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to sign up: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
