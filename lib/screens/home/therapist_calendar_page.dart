import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../providers/therapist_provider.dart';
import '../../providers/auth_provider.dart'; // Added auth provider import
import '../../utils/api_endpoints.dart';
import '../../app_router.dart';

class TherapistCalendarPage extends StatefulWidget {
  const TherapistCalendarPage({Key? key}) : super(key: key);

  @override
  State<TherapistCalendarPage> createState() => _TherapistCalendarPageState();
}

class _TherapistCalendarPageState extends State<TherapistCalendarPage> {
  List<DateTime> availableDates = [];
  DateTime? selectedDate;
  bool isLoading = true;
  String? error;

  int? therapistId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // First, try to get therapist ID from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null) {
      // Handle different argument types
      if (args is int) {
        therapistId = args;
      } else if (args is String) {
        therapistId = int.tryParse(args);
      } else if (args is Map<String, dynamic> && args.containsKey('id')) {
        therapistId = args['id'];
      }
    }

    // If no ID from arguments, try to get from provider
    if (therapistId == null) {
      final therapistProvider = Provider.of<TherapistProvider>(context, listen: false);
      final therapistData = therapistProvider.selectedTherapist;

      if (therapistData != null && therapistData.containsKey('id')) {
        therapistId = therapistData['id'];
      }
    }

    // If we have an ID, fetch availability
    if (therapistId != null) {
      _fetchAvailability(therapistId!);
    } else {
      setState(() {
        isLoading = false;
        error = 'No therapist ID available. Please go back and try again.';
      });
    }
  }

  Future<void> _fetchAvailability(int id) async {
    try {
      // Get the auth token from your provider
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;

      if (token == null) {
        setState(() {
          isLoading = false;
          error = 'Authentication token not found. Please log in again.';
        });
        return;
      }

      // Include the token in your request headers
      final response = await http.get(
          Uri.parse(AvailabilityEndpoints.byTherapist(id)),
          headers: {
            'Authorization': 'Bearer $token',
          }
      );

      print("Availability response status: ${response.statusCode}");
      print("Availability response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Parsed data: $data");

        try {
          List<DateTime> parsedDates = [];

          for (var dateStr in data) {
            try {
              // Handle possible formats and clean the string
              String cleanDateStr = dateStr.toString().trim();
              print("Parsing date: $cleanDateStr");

              // Try parsing with DateTime.parse which handles ISO format
              DateTime parsedDate = DateTime.parse(cleanDateStr);
              parsedDates.add(parsedDate);
            } catch (e) {
              print("Error parsing individual date '$dateStr': $e");
              // Continue with other dates even if one fails
            }
          }

          setState(() {
            availableDates = parsedDates;
            isLoading = false;

            if (parsedDates.isEmpty && data.isNotEmpty) {
              error = 'Could not parse any dates from the response';
            }
          });

          print("Successfully parsed ${parsedDates.length} dates");
        } catch (parseError) {
          print("Date parsing error: $parseError");
          setState(() {
            isLoading = false;
            error = 'Error parsing dates: $parseError';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          error = 'Failed to load availability: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      print("Exception in _fetchAvailability: $e");
      setState(() {
        isLoading = false;
        error = 'Error: $e';
      });
    }
  }

  bool _isAvailable(DateTime day) {
    return availableDates.any((d) =>
    d.year == day.year && d.month == day.month && d.day == day.day);
  }

  void _onDaySelected(DateTime selected, DateTime _) {
    if (_isAvailable(selected)) {
      setState(() {
        selectedDate = selected;
      });
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
          : error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Please pick an available day',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime(DateTime.now().year, DateTime.now().month + 2, 0),
              focusedDay: selectedDate ?? DateTime.now(),
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              selectedDayPredicate: (day) {
                return selectedDate != null &&
                    selectedDate!.year == day.year &&
                    selectedDate!.month == day.month &&
                    selectedDate!.day == day.day;
              },
              enabledDayPredicate: _isAvailable,
              onDaySelected: _onDaySelected,
            ),
            const Spacer(),
            if (selectedDate != null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "To keep this platform affordable and for everybody, you cannot cancel or edit your appointment date",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: selectedDate != null && therapistId != null
                        ? () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.packages,
                        arguments: {
                          'therapistId': therapistId,
                          'selectedDate': selectedDate,
                        },
                      );
                    }
                        : null,
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}