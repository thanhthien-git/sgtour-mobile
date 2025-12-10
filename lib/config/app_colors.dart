import 'package:flutter/material.dart';

/// Central color configuration for the app
/// Modify these colors to change the app's color scheme
class AppColors {
  // ============ Light Theme Colors ============
  // Primary Colors

  // primary color provided by user: 66C076
  static const Color primary = Color(0xFF66C076);

  // gray color provided by user: 0E1025
  static const Color darkGray = Color(0xFF0E1025);

  // surface and text colors (adjustable)
  static const Color text = darkGray;
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary Colors
  static const Color secondary = Color(0xFFFFA726); // Secondary Orange
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFFB8C00);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF66BB6A); // Tertiary Green
  static const Color tertiaryLight = Color(0xFF81C784);
  static const Color tertiaryDark = Color(0xFF43A047);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // ============ Dark Theme Colors ============
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color inputBackgroundDark = Color(0xFF2C2C2C);
  static const Color borderDark = Color(0xFF424242);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textTertiaryDark = Color(0xFF757575);

  // ============ Semantic Colors ============
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x33000000);
}
