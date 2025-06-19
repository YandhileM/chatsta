// lib/core/constants/api_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl = dotenv.env['BASE_URL'] ?? '';
  static String privateKey = dotenv.env['PROJECT_ID'] ?? '';
  static String projectId = dotenv.env['PROJECT_ID'] ?? '';
}
