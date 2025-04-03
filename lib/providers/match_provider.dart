import 'package:flutter/material.dart';
import '../models/therapist.dart';
import '../services/matching_service.dart';

class MatchProvider extends ChangeNotifier {
  final MatchingService _matchingService = MatchingService();

  List<Therapist> _matches = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Therapist> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLatestMatches(String token) async {
    _setLoading(true);
    try {
      final result = await _matchingService.getLatestMatches(token);
      _matches = result;
      _errorMessage = null;
    } catch (e) {
      _matches = [];
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _matches = [];
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
