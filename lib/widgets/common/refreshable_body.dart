import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';

class RefreshableBody extends StatelessWidget {
  final Future<void> Function() onRefresh;

  final Widget child;

  final EdgeInsetsGeometry? padding;

  const RefreshableBody({
    super.key,
    required this.onRefresh,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
