import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';

class TherapistService {
  // Fetch therapist details including bio
  Future<Map<String, dynamic>> getTherapistDetails(int therapistId, String token) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/therapists/$therapistId');

    debugPrint('Fetching therapist details from: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Ensure all expected fields exist
        final Map<String, dynamic> normalizedData = {
          'id': data['id'] ?? therapistId,
          'full_name': data['full_name'] ?? data['name'] ?? 'Unknown Therapist',
          'bio': data['bio'] ?? 'Bio not available',
          'profile_picture_url': data['profile_picture_url'] ?? '',
          'match_score': data['match_score'] ?? 0.0,
        };

        return normalizedData;
      } else {
        debugPrint('Error fetching therapist details: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to load therapist details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in getTherapistDetails: $e');

      // Return fallback data in case of error to prevent null issues
      return {
        'id': therapistId,
        'full_name': 'Therapist $therapistId',
        'bio': 'Unable to load bio. Please try again later.',
        'profile_picture_url': '',
        'match_score': 0.0,
      };
    }
  }
}