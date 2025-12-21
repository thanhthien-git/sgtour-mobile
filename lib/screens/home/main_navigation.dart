import 'package:flutter/material.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import 'explore_screen.dart';
import 'map/map_screen.dart';
import 'profile/profile_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<BottomNavItem> _getNavItems(BuildContext context) {
    final l10n = context.l10n;
    return [
      BottomNavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: l10n.nav_explore,
      ),
      BottomNavItem(
        icon: Icons.location_on_outlined,
        activeIcon: Icons.location_on,
        label: l10n.nav_map,
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: l10n.nav_profile,
      ),
      BottomNavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: l10n.nav_settings,
      ),
    ];
  }

  final List<Widget> _screens = const [
    ExploreScreen(),
    MapScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: _getNavItems(context),
      ),
    );
  }
}
