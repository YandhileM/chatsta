import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';


class UserService {
  final String baseUrl = ApiConstants.baseUrl;
  final String privateKey = ApiConstants.privateKey;

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/'),
        headers: {
          'Project-ID': privateKey,
        },
      );

      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        return users.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
