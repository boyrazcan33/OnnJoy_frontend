import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/entry_service.dart';

class EntryProvider extends ChangeNotifier {
  final EntryService _entryService = EntryService();

  String _text = '';
  String _language = 'en';
  bool _isLoading = false;
  String? _errorMessage;
  bool _submitted = false;

  String get text => _text;
  String get language => _language;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSubmitted => _submitted;
  int get remainingCharacters => 1000 - _text.length;

  void updateText(String value) {
    if (value.length <= 1000) {
      _text = value;
      notifyListeners();
    }
  }

  void updateLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  Future<void> submitEntry(String token) async {
    _setLoading(true);
    try {
      final entry = EntryRequest(language: _language, text: _text);
      await _entryService.submitEntry(entry: entry, token: token);
      _submitted = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _submitted = false;
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _text = '';
    _submitted = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
