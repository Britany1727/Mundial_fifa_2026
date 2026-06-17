import 'package:flutter/material.dart';
import 'groups_screen.dart';
import 'home_screen.dart';
import 'stadiums_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    GroupsScreen(),
    StadiumsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF0A1A2A),
        selectedItemColor: const Color(0xFFFFC300),
        unselectedItemColor: const Color(0xFF8FA8C0),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Partidos'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Grupos'),
          BottomNavigationBarItem(icon: Icon(Icons.stadium), label: 'Estadios'),
        ],
      ),
    );
  }
}
