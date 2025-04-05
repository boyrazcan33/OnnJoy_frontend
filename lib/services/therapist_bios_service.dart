// In a new file lib/services/therapist_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';

class TherapistService {
  // Fetch therapist details including bio
  Future<Map<String, dynamic>> getTherapistDetails(int therapistId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/therapists/$therapistId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load therapist details');
    }
  }
}