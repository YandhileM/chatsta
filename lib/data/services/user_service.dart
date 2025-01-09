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
          'PRIVATE-KEY': privateKey,
        },
      );

      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        return users.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch users. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}
