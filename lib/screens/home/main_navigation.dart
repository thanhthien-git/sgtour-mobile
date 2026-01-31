import 'package:flutter/material.dart';
import 'package:sgtourcus/screens/home/news/news_screen.dart';
import 'package:sgtourcus/screens/qr_scanner_screen.dart';
import 'package:sgtourcus/widgets/common/nav_aware_scaffold.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
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
  bool _hideNavBar = false;

  List<BottomNavItem> _getNavItems(BuildContext context) {
    final l10n = context.l10n;
    return [
      BottomNavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: l10n.nav_explore,
      ),

      BottomNavItem(
        icon: Icons.newspaper_outlined,
        activeIcon: Icons.newspaper,
        label: l10n.nav_news,
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

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _setNavBarVisibility(bool visible) {
    setState(() => _hideNavBar = !visible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MapScreen(onNavBarVisibilityChanged: _setNavBarVisibility),
          const NavAwareScaffold(child: NewsScreen()),
          const NavAwareScaffold(child: ProfileScreen()),
          const NavAwareScaffold(child: SettingsScreen()),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _hideNavBar
          ? null
          : BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              items: _getNavItems(context),
              onCenterButtonTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                );
              },
            ),
    );
  }
}
