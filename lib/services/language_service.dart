import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';

class LanguageService {
  // Update user's language preference in the backend
  Future<bool> updateUserLanguage({
    required String language,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/user/language'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'language': language,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating language: $e');
      return false;
    }
  }
}