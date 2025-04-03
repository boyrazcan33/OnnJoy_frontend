import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityCalendar extends StatefulWidget {
  final List<DateTime> initiallySelected;
  final Function(List<DateTime>) onChanged;

  const AvailabilityCalendar({
    Key? key,
    required this.initiallySelected,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late List<DateTime> _selectedDates;

  @override
  void initState() {
    super.initState();
    _selectedDates = [...widget.initiallySelected];
  }

  void _onDayTapped(DateTime day, DateTime _) {
    setState(() {
      if (_selectedDates.contains(day)) {
        _selectedDates.remove(day);
      } else {
        _selectedDates.add(day);
      }
    });

    widget.onChanged(_selectedDates);
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime(DateTime.now().year, DateTime.now().month + 2, 0),
      focusedDay: DateTime.now(),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        selectedDecoration: BoxDecoration(
          color: Color(0xFF005C65),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Color(0xFF94A3B8),
          shape: BoxShape.circle,
        ),
      ),
      selectedDayPredicate: (day) {
        return _selectedDates.any((selected) =>
        selected.year == day.year &&
            selected.month == day.month &&
            selected.day == day.day);
      },
      onDaySelected: _onDayTapped,
      calendarFormat: CalendarFormat.month,
    );
  }
}
