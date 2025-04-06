import 'package:flutter/material.dart';
import '../services/therapist_bios_service.dart';

class TherapistProvider extends ChangeNotifier {
  final TherapistService _therapistService = TherapistService();

  Map<String, dynamic>? _selectedTherapist;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get selectedTherapist => _selectedTherapist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set therapist data directly (from match card)
  void setSelectedTherapist(Map<String, dynamic> therapistData) {
    debugPrint("TherapistProvider: Setting therapist data: $therapistData");

    // Create a new map to avoid reference issues
    _selectedTherapist = Map<String, dynamic>.from(therapistData);
    _error = null;

    debugPrint("TherapistProvider: Data set successfully, notifying listeners");
    notifyListeners();
  }

  // Fetch therapist data from API by ID
  Future<void> fetchTherapistById(int id, String token) async {
    debugPrint("TherapistProvider: Fetching therapist with ID: $id");

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _therapistService.getTherapistDetails(id, token);
      debugPrint("TherapistProvider: API data received: $data");

      _selectedTherapist = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("TherapistProvider: Error fetching therapist: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // For debugging - print current state
  void printState() {
    debugPrint("TherapistProvider STATE:");
    debugPrint("  Has therapist: ${_selectedTherapist != null}");
    debugPrint("  Therapist data: $_selectedTherapist");
    debugPrint("  Is loading: $_isLoading");
    debugPrint("  Error: $_error");
  }

  // Clear data
  void clearSelectedTherapist() {
    debugPrint("TherapistProvider: Clearing therapist data");
    _selectedTherapist = null;
    _error = null;
    notifyListeners();
  }
}