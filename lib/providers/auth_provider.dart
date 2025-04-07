import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _user?.token;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.login(email: email, password: password);
      _errorMessage = null;
      print("Token received and stored: ${_user?.token?.substring(0, 15)}..."); // Only print first 15 chars for security

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(String email, String password, String language) async {
    _setLoading(true);
    try {
      _user = await _authService.signup(
        email: email,
        password: password,
        language: language,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Update user's language preference
  Future<bool> updateLanguage(String language) async {
    if (!isAuthenticated || token == null) {
      return false;
    }

    try {
      final success = await _authService.updateLanguage(
        language: language,
        token: token!,
      );

      if (success && _user != null) {
        // Update local user model
        _user = User(
          id: _user!.id,
          email: _user!.email,
          anonUsername: _user!.anonUsername,
          language: language,  // Update with new language
          token: _user!.token,
        );
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}