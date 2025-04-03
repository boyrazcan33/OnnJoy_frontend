import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry.dart';
import '../utils/api_endpoints.dart';

class EntryService {
  Future<void> submitEntry({
    required EntryRequest entry,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse(EntryEndpoints.submitEntry),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(entry.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit entry: ${response.body}');
    }
  }
}
