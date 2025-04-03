import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/api_endpoints.dart';
import '../../app_router.dart'; // for AppRoutes constant

class TherapistCalendarPage extends StatefulWidget {
  const TherapistCalendarPage({Key? key}) : super(key: key);

  @override
  State<TherapistCalendarPage> createState() => _TherapistCalendarPageState();
}

class _TherapistCalendarPageState extends State<TherapistCalendarPage> {
  List<DateTime> availableDates = [];
  DateTime? selectedDate;
  bool isLoading = true;

  late int therapistId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as int?;
    if (args != null) {
      therapistId = args;
      _fetchAvailability();
    }
  }

  Future<void> _fetchAvailability() async {
    final url = '${AvailabilityEndpoints.byTherapist}/$therapistId';
    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          availableDates = data.map((d) => DateTime.parse(d)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch availability');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Image.asset('assets/icons/step-backward.png', height: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    onPressed: selectedDate != null
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
