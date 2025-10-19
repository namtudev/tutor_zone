import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main shell screen with responsive navigation (rail for desktop, bottom nav for mobile)
///
/// This screen uses GoRouter's StatefulNavigationShell to maintain navigation state
/// across tab switches and enable URL-based navigation.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell and container for the branch Navigators
  final StatefulNavigationShell navigationShell;

  /// Navigation items configuration (immutable)
  static final _navigationItems = IList<_NavigationItem>(const [
    _NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Students',
    ),
    _NavigationItem(
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
      label: 'Timer',
    ),
    _NavigationItem(
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments,
      label: 'Payments',
    ),
    _NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Reports',
    ),
    _NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ]);

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
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle),
                  onSelected: (value) {
                    // TODO: Handle menu actions
                    switch (value) {
                      case 'profile':
                        // Navigate to profile
                        break;
                      case 'settings':
                        // Navigate to settings tab
                        _onTap(context, 5); // Settings is index 5
                      case 'logout':
                        // Handle logout
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'profile', child: Text('Profile')),
                    PopupMenuItem(value: 'settings', child: Text('Settings')),
                    PopupMenuDivider(),
                    PopupMenuItem(value: 'logout', child: Text('Logout')),
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
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) => _onTap(context, index),
                  labelType: NavigationRailLabelType.all,
                  destinations: _navigationItems
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),

              // Vertical divider
              if (useNavigationRail) const VerticalDivider(thickness: 1, width: 1),

              // Main content area - StatefulNavigationShell handles child screens
              Expanded(child: navigationShell),
            ],
          ),

          // Bottom navigation bar for mobile
          bottomNavigationBar: useNavigationRail
              ? null
              : NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) => _onTap(context, index),
                  destinations: _navigationItems
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }

  /// Handle navigation item tap
  ///
  /// Uses goBranch to navigate to the selected tab while preserving state.
  /// If the same tab is tapped, it navigates to the initial location of that branch.
  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      // Navigate to initial location when tapping the same item
      // This provides a "reset to root" behavior for the current tab
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Navigation item configuration (immutable)
@immutable
class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
