// dart
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class DotsIndicator extends StatelessWidget {
  final int count;
  final int index;
  final double size;
  final double spacing;

  const DotsIndicator({
    super.key,
    required this.count,
    required this.index,
    this.size = 8,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? size * 2 : size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.text.withOpacity(0.15),
            borderRadius: BorderRadius.circular(size),
          ),
        );
      }),
    );
  }
}
