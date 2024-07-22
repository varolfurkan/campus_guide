import 'package:campus_guide/screens/events_screen.dart';
import 'package:campus_guide/screens/student_clubs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavigator extends StatefulWidget {
  final Widget homePage;

  const BottomNavigator({super.key, required this.homePage});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      widget.homePage,
      const StudentClubs(),
      const Center(child: Text('AI Mentor')),
      const EventScreen(),
      const Center(child: Text('Digital Library')),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF007BFF),
        items:  <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.users),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: ClipOval(
                child: Image.asset('img/icons/ai_mentor.png', width: 35, height: 35, fit: BoxFit.cover),
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidCalendarDays),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.comments),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
