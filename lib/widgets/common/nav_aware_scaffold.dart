import 'package:flutter/material.dart';

class NavAwareScaffold extends StatelessWidget {
  final Widget child;

  const NavAwareScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    const navBarHeight = 80.0;
    return Padding(
      padding: EdgeInsets.only(bottom: navBarHeight),
      child: child,
    );
  }
}
