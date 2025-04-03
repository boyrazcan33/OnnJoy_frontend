import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/therapist.dart';
import '../utils/api_endpoints.dart';

class MatchingService {
  /// Triggers AI matching manually for a given entry (optional)
  Future<List<Therapist>> matchEntry(int entryId, String token) async {
    final response = await http.post(
      Uri.parse(MatchEndpoints.matchEntry(entryId)),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Therapist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to match entry: ${response.body}');
    }
  }

  /// Gets the latest two therapist matches for the logged-in user
  Future<List<Therapist>> getLatestMatches(String token) async {
    final response = await http.get(
      Uri.parse(MatchEndpoints.latestMatch),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Therapist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load latest matches: ${response.body}');
    }
  }
}
