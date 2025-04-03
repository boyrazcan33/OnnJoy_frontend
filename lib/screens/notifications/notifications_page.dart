import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/api_endpoints.dart';

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
    final unread = notifications.where((n) => n['read'] == false);
    final futures = unread.map(
          (n) => http.post(Uri.parse(NotificationEndpoints.markRead(n['id']))),
    );

    await Future.wait(futures);
    _fetchNotifications();
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
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
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
              child: const Text('Mark All Read'),
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
            const Text('Enter pre-session mail:'),
            const SizedBox(height: 8),
            TextField(
              controller: _preSessionController,
              maxLength: 1000,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write something for your therapist...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _savePreSessionMessage,
              child: const Text('Save Message'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _handleJoinAppointment,
              child: const Text('Join Appointment'),
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Image.asset('assets/icons/step-backward.png', height: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
