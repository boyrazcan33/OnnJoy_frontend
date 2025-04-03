import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../utils/api_endpoints.dart';

class NotificationService {
  /// Fetches all notifications for the current user
  Future<List<AppNotification>> getUserNotifications(String token) async {
    final response = await http.get(
      Uri.parse(NotificationEndpoints.all),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => AppNotification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications: ${response.body}');
    }
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(int id, String token) async {
    final response = await http.post(
      Uri.parse(NotificationEndpoints.markRead(id)), // <== düzeltildi
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read: ${response.body}');
    }
  }
}
