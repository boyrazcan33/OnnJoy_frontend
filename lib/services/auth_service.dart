import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/api_endpoints.dart';

class AuthService {
  Future<User> signup({
    required String email,
    required String password,
    required String language,
  }) async {
    final response = await http.post(
      Uri.parse(AuthEndpoints.signup),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'languagePreference': language,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      return _fetchUserWithToken(token);
    } else {
      throw Exception('Signup failed: ${response.body}');
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(AuthEndpoints.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      return _fetchUserWithToken(token);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<User> _fetchUserWithToken(String token) async {
    print("Sending request with token: ${token.substring(0, 15)}..."); // Security: only print part

    final response = await http.get(
      Uri.parse(UserEndpoints.me),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      userData['token'] = token;
      return User.fromJson(userData);
    } else {
      throw Exception('Failed to fetch user details: ${response.body}');
    }
  }
}
