import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font Family
  static const String fontFamily = 'Inter'; // Change to your preferred font

  // ============ Headings ============
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ============ Body Text ============
  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  // ============ Button Text ============
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ============ Special Styles ============
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );
}
