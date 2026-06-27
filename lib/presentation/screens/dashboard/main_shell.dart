import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/responsive_layout.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/tasks')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/calendar');
        break;
      case 3:
        context.go('/tasks');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  static const _navItems = [
    (
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: PersianStrings.dashboard,
    ),
    (
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat,
      label: PersianStrings.chat,
    ),
    (
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: PersianStrings.calendar,
    ),
    (
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist,
      label: PersianStrings.tasks,
    ),
    (
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: PersianStrings.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _currentIndex(context);

    return ResponsiveLayout(
      mobile: _mobileLayout(context, selectedIndex),
      desktop: _desktopLayout(context, selectedIndex),
    );
  }

  Widget _mobileLayout(BuildContext context, int selectedIndex) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        height: 64,
        destinations: _navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _desktopLayout(BuildContext context, int selectedIndex) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => _onTap(context, i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppTheme.surface,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(Icons.auto_awesome, size: 32, color: AppTheme.gold),
            ),
            destinations: _navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: Text(
                      item.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
          ),
          Container(width: 1, color: AppTheme.divider),
          Expanded(child: ContentContainer(child: child)),
        ],
      ),
    );
  }
}
