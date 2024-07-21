import 'dart:convert';
import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _addEvent(String event) {
    if (_events[_selectedDay] != null) {
      _events[_selectedDay]!.add(event);
    } else {
      _events[_selectedDay] = [event];
    }
    setState(() {});
  }

  void _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString('events') ?? '{}';
    final eventsMap = json.decode(eventsString) as Map<String, dynamic>;
    _events = eventsMap.map((key, value) {
      final date = DateTime.parse(key);
      final eventsList = List<String>.from(value);
      return MapEntry(date, eventsList);
    });
    setState(() {});
  }

  void _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsMap = _events.map((key, value) {
      final date = key.toIso8601String();
      return MapEntry(date, value);
    });
    final eventsString = json.encode(eventsMap);
    prefs.setString('events', eventsString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.read<UserCubit>().navigateToProfile(context);
          },
          child: const Icon(FontAwesomeIcons.user, color: Colors.white),
        ),
        title: const Text('Etkinlik Takvimi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF007BFF),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(FontAwesomeIcons.bell, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              locale: 'tr_TR',  // Keep this to ensure calendar displays in Turkish
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },  // Remove other formats
              eventLoader: _getEventsForDay,
            ),
            ..._getEventsForDay(_selectedDay).map((event) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.blueAccent),
                  title: Text(event, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat.yMMMMd('tr_TR').format(_selectedDay)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _events[_selectedDay]!.remove(event);
                        _saveEvents();
                      });
                    },
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        backgroundColor: const Color(0xFF007BFF),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog() {
    TextEditingController eventController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinlik Ekle'),
        content: TextField(
          controller: eventController,
          decoration: const InputDecoration(hintText: 'Etkinlik Adı'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (eventController.text.isNotEmpty) {
                _addEvent(eventController.text);
                _saveEvents();  // Save events after adding a new one
              }
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
