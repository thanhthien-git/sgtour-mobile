import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final double height;
  final Widget icon;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    this.height = 60,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey[700]! : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[900] : Colors.white,
        ),
        child: Center(child: icon),
      ),
    );
  }
}
