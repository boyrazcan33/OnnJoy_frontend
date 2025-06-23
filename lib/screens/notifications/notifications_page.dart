import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/api_endpoints.dart';
import '../../widgets/common/translate_text.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  int newCount = 0;
  final TextEditingController _preSessionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse(NotificationEndpoints.getAll),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          notifications = data;
          newCount = data.where((n) => n['read'] == false).length;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      debugPrint('Notification error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final unread = notifications.where((n) => n['read'] == false).toList();

    if (unread.isEmpty) {
      // No unread notifications to mark
      return;
    }

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      // Create a list of futures for each mark-as-read request
      final futures = unread.map(
            (n) => http.post(
          Uri.parse(NotificationEndpoints.markRead(n['id'])),
          headers: {'Authorization': 'Bearer ${auth.token}'},
        ),
      );

      await Future.wait(futures);

      setState(() {
        // Update the 'read' status of all notifications to true
        notifications = notifications.map((n) {
          return {...n, 'read': true};
        }).toList();

        // Update the count of unread notifications
        newCount = 0;
      });
    } catch (e) {
      debugPrint('Mark all read error: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark notifications as read: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _savePreSessionMessage() {
    final text = _preSessionController.text.trim();
    if (text.isNotEmpty) {
      // You may send to backend here if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pre-session message saved')),
      );
    }
  }

  void _handleJoinAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Join link will open 5 mins before session')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TranslateText('notifications'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (newCount > 0)
              Text('+New ($newCount)', style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 8),
            TextButton(
              onPressed: _markAllRead,
              child: TranslateText('markAllRead'),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return Card(
                    color: n['read'] ? Colors.white : Colors.teal.shade50,
                    child: ListTile(
                      title: Text(n['message'] ?? ''),
                      subtitle: Text(n['type'] ?? ''),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            TranslateText('enterPreSessionMail'),
            const SizedBox(height: 8),
            TextField(
              controller: _preSessionController,
              maxLength: 1000,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: languageProvider.translate('writeForTherapist'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _savePreSessionMessage,
              child: TranslateText('saveMessage'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _handleJoinAppointment,
              child: TranslateText('joinAppointment'),
            ),
          ],
        ),
      ),
    );
  }
}