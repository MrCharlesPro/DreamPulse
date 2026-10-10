import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'record_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;
  final _pantallas = const [
    DashboardScreen(),
    RecordScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_indice), child: _pantallas[_indice]),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _indice,
      onDestinationSelected: (indice) => setState(() => _indice = indice),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.nightlight_outlined),
          selectedIcon: Icon(Icons.nightlight),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Registrar',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Historial',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    ),
  );
}
