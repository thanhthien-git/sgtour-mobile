// dart
import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class OnboardData {
  final String title;
  final String description;
  final String imageAsset;

  const OnboardData({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}

class OnboardPage extends StatelessWidget {
  final OnboardData data;
  const OnboardPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 6,
          child: Image.asset(data.imageAsset, fit: BoxFit.cover),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.75),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
