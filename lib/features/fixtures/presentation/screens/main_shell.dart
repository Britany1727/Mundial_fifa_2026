import 'package:flutter/material.dart';
import 'groups_screen.dart';
import 'home_screen.dart';
import 'stadiums_screen.dart';
import '../theme/wc_colors.dart';

// Misma paleta usada en las otras pantallas. Si ya tienes WcColors en un
// archivo compartido, borra este bloque e impórtalo desde ahí.
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

  static const _icons = [Icons.sports_soccer, Icons.group, Icons.stadium];
  static const _labels = ['Partidos', 'Grupos', 'Estadios'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WcColors.bgLight,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: WcColors.navy,
          border: Border(
            top: BorderSide(color: WcColors.divider.withValues(alpha: 0.4), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_icons.length, (i) {
                final selected = i == _currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _currentIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? WcColors.tealPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Forma de píldora estilizada como el botón "Partidos"
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[i],
                            size: 20,
                            color: selected ? Colors.white : WcColors.textMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _labels[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : WcColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
