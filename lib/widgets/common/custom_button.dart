import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonStyle? style;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.style,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = _getForegroundColor(isDark);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style ?? _getDefaultStyle(isDark),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
              ),
            )
          : Text(
              label,
              style:
                  textStyle ??
                  AppTextStyles.button.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
    );
  }

  ButtonStyle _getDefaultStyle(bool isDark) {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(isDark),
      foregroundColor: _getForegroundColor(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: _getBorderSide(isDark),
      ),
      elevation: 0,
      disabledBackgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
    );
  }

  Color _getBackgroundColor(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return isDark ? Colors.grey[800]! : Colors.grey[200]!;
      case ButtonVariant.outline:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return isDark ? Colors.white : AppColors.text;
      case ButtonVariant.outline:
        return AppColors.primary;
    }
  }

  BorderSide _getBorderSide(bool isDark) {
    if (variant == ButtonVariant.outline) {
      return BorderSide(color: AppColors.primary, width: 1.5);
    }
    return BorderSide.none;
  }
}

enum ButtonVariant { primary, secondary, outline }
