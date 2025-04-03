import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/api_endpoints.dart';

class UserAppointmentsPage extends StatefulWidget {
  const UserAppointmentsPage({Key? key}) : super(key: key);

  @override
  State<UserAppointmentsPage> createState() => _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends State<UserAppointmentsPage> {
  List<dynamic> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse(AppointmentEndpoints.all),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          appointments = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      setState(() => isLoading = false);
    }
  }

  String formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      return DateFormat('yyyy-MM-dd – HH:mm').format(date);
    } catch (_) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
          ? const Center(child: Text('No appointments found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appt) {
    final String fullName = appt['full_name'] ?? 'Therapist';
    final String package = appt['package_type'] ?? 'N/A';
    final String date =
    appt['scheduled_at'] != null ? formatDate(appt['scheduled_at']) : 'Unknown';
    final String? message = appt['pre_session_message'];
    final String status = (appt['status'] ?? 'unknown').toString().toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            appt['profile_picture_url'] ?? 'https://via.placeholder.com/100',
          ),
          radius: 30,
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Package: $package"),
            Text("Date: $date"),
            if (message != null && message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Message: $message",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Status: $status ✅",
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
