import 'package:flutter/material.dart';
import 'package:tutor_zone/features/dashboard/screens/dashboard_screen.dart';
import 'package:tutor_zone/features/payments/screens/payments_screen.dart';
import 'package:tutor_zone/features/reports/screens/monthly_summary_screen.dart';
import 'package:tutor_zone/features/settings/screens/settings_screen.dart';
import 'package:tutor_zone/features/students/screens/students_list_screen.dart';
import 'package:tutor_zone/features/timer/screens/session_timer_screen.dart';

/// Main shell screen with responsive navigation (rail for desktop, bottom nav for mobile)
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Dashboard'),
    _NavigationItem(icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Students'),
    _NavigationItem(icon: Icons.timer_outlined, selectedIcon: Icons.timer, label: 'Timer'),
    _NavigationItem(icon: Icons.payments_outlined, selectedIcon: Icons.payments, label: 'Payments'),
    _NavigationItem(icon: Icons.analytics_outlined, selectedIcon: Icons.analytics, label: 'Reports'),
    _NavigationItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use navigation rail for wide screens, bottom nav for narrow
        final useNavigationRail = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tutor Zone'),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle),
                  onSelected: (value) {},
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'profile', child: Text('Profile')),
                    const PopupMenuItem(value: 'settings', child: Text('Settings')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
                ),
              ),
            ],
          ),
          body: Row(
            children: [
              // Navigation rail for desktop/tablet
              if (useNavigationRail)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: _navigationItems
                      .map((item) => NavigationRailDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: Text(item.label)))
                      .toList(),
                ),

              // Vertical divider
              if (useNavigationRail) const VerticalDivider(thickness: 1, width: 1),

              // Main content area
              Expanded(child: _getSelectedScreen()),
            ],
          ),
          // Bottom navigation bar for mobile
          bottomNavigationBar: useNavigationRail
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: _navigationItems
                      .map((item) => NavigationDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: item.label))
                      .toList(),
                ),
        );
      },
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const StudentsListScreen();
      case 2:
        return const SessionTimerScreen();
      case 3:
        return const PaymentsScreen();
      case 4:
        return const MonthlySummaryScreen();
      case 5:
        return const SettingsScreen();
      default:
        return const Center(child: Text('Unknown Screen'));
    }
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  _NavigationItem({required this.icon, required this.selectedIcon, required this.label});
}
