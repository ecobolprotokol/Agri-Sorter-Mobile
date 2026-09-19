import 'package:flutter/material.dart';

import 'camera_sorting_screen.dart';
import 'calibration_screen.dart';
import 'commodity_screen.dart';
import 'dashboard_screen.dart';
import 'dataset_screen.dart';
import 'history_screen.dart';
import 'real_camera_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';
import 'sorting_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onNavigate: _onItemTapped),
      const SortingScreen(),
      const CameraSortingScreen(),
      const RealCameraScreen(),
      const CommodityScreen(),
      const DatasetScreen(),
      const CalibrationScreen(),
      const HistoryScreen(),
      const ReportScreen(),
      const SettingsScreen(),
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
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_arrow_rounded),
            label: 'Sortir',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Camera',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Preview',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_rounded),
            label: 'Komoditas',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_rounded),
            label: 'Dataset',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: 'Kalibrasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_rounded),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
