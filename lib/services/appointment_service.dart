import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import '../utils/api_endpoints.dart';

class AppointmentService {
  /// Fetches appointments for the logged-in user
  Future<List<Appointment>> getAppointments(String token) async {
    final response = await http.get(
      Uri.parse(UserEndpoints.appointments),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments: ${response.body}');
    }
  }

  /// Books appointments for selected dates based on the package type
  Future<void> bookAppointments({
    required int userId,
    required int therapistId,
    required String packageType,
    required List<DateTime> selectedDates,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse(UserEndpoints.appointments),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'therapistId': therapistId,
        'packageType': packageType,
        'selectedDates': selectedDates.map((d) => d.toIso8601String().split('T').first).toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to book appointment(s): ${response.body}');
    }
  }
}
