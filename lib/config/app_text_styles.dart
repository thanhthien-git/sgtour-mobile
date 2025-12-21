import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; //
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.beVietnamPro(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.beVietnamPro(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.beVietnamPro(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle heading4 = GoogleFonts.beVietnamPro(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle heading5 = GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle body1 = GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle body2 = GoogleFonts.beVietnamPro(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  static TextStyle button = GoogleFonts.beVietnamPro(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle subtitle1 = GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle subtitle2 = GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1,
    color: AppColors.textSecondary,
  );

  static TextStyle subtitle3 = GoogleFonts.beVietnamPro(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1,
    color: AppColors.textSecondary,
  );

  static TextStyle overline = GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );
}
