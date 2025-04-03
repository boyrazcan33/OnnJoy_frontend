import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications(String token) async {
    _setLoading(true);
    try {
      final result = await _notificationService.getUserNotifications(token);
      _notifications = result;
      _errorMessage = null;
    } catch (e) {
      _notifications = [];
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(int id, String token) async {
    try {
      await _notificationService.markAsRead(id, token);
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return AppNotification(
            id: n.id,
            userId: n.userId,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void reset() {
    _notifications = [];
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
