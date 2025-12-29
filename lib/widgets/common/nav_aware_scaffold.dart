import 'package:flutter/material.dart';

class NavAwareScaffold extends StatelessWidget {
  final Widget child;

  const NavAwareScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: child,
    );
  }
}
