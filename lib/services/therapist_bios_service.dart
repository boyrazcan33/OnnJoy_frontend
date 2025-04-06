import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/api_endpoints.dart';

class TherapistService {
  // Fetch therapist details by therapist ID
  Future<Map<String, dynamic>> getTherapistById(int therapistId, String token) async {
    final Uri url = Uri.parse(TherapistEndpoints.getTherapistDetails(therapistId));

    debugPrint('Fetching therapist details from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Therapist details response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load therapist details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching therapist details: $e');
      throw e;
    }
  }

  // Fetch therapist by rank from match results (useful for initial therapist info)
  Future<Map<String, dynamic>> getTherapistFromMatch(int rank, String token) async {
    // First fetch the matches
    final response = await http.get(
      Uri.parse(MatchEndpoints.latestMatch),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> matches = jsonDecode(response.body);
      // Find the match with the specified rank
      final matchWithRank = matches.firstWhere(
              (match) => match['rank'] == rank,
          orElse: () => null
      );

      if (matchWithRank != null) {
        // Use the therapist_id from the match to fetch full details
        final int therapistId = matchWithRank['therapist_id'];
        if (therapistId != null) {
          return getTherapistById(therapistId, token);
        } else {
          throw Exception('Match found but no therapist_id is available');
        }
      } else {
        throw Exception('No match found with rank: $rank');
      }
    } else {
      throw Exception('Failed to load matches: ${response.statusCode}');
    }
  }

  // A combination method that tries different approaches to get therapist details
  Future<Map<String, dynamic>> getTherapistDetails(int id, String token) async {
    try {
      // First try the direct therapist endpoint
      return await getTherapistById(id, token);
    } catch (e) {
      debugPrint('Error with direct therapist lookup: $e');

      // If that fails, try interpreting the ID as a rank
      try {
        return await getTherapistFromMatch(id, token);
      } catch (e2) {
        debugPrint('Error with match-based lookup: $e2');

        // At this point, both methods have failed
        throw Exception('Could not retrieve therapist details');
      }
    }
  }
}