import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading1.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        headlineMedium: AppTextStyles.heading4,
        titleLarge: AppTextStyles.heading5,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading1.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.button,
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        tertiary: AppColors.tertiaryDark,
        error: AppColors.error,
        surface: AppColors.surfaceDark,
      ),
    );
  }
}
