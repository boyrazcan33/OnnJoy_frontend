import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBooked = false;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBooked => _isBooked;

  Future<void> fetchAppointments(String token) async {
    _setLoading(true);
    try {
      final result = await _appointmentService.getAppointments(token);
      _appointments = result;
      _errorMessage = null;
    } catch (e) {
      _appointments = [];
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> bookAppointments({
    required int userId,
    required int therapistId,
    required String packageType,
    required List<DateTime> selectedDates,
    required String token,
  }) async {
    _setLoading(true);
    try {
      await _appointmentService.bookAppointments(
        userId: userId,
        therapistId: therapistId,
        packageType: packageType,
        selectedDates: selectedDates,
        token: token,
      );
      _isBooked = true;
      _errorMessage = null;
      await fetchAppointments(token);
    } catch (e) {
      _isBooked = false;
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _appointments = [];
    _errorMessage = null;
    _isBooked = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
