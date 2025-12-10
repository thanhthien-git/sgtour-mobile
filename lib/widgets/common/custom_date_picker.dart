import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

/// Reusable date picker field with consistent styling
class CustomDatePicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final Widget? prefixIcon;
  final String? hintText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? dateFormat;
  final double? width;
  final double? height;

  const CustomDatePicker({
    super.key,
    this.value,
    this.onChanged,
    this.prefixIcon,
    this.hintText,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = DateFormat(dateFormat ?? 'MMM dd, yyyy');
    final fieldHeight = height ?? 56;

    Widget datePicker = GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: fieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 12)],
            Expanded(
              child: Text(
                value != null ? formatter.format(value!) : (hintText ?? ''),
                style: AppTextStyles.body1.copyWith(
                  color: value != null
                      ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)
                      : (isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiary),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: datePicker);
    }

    return datePicker;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && onChanged != null) {
      onChanged!(picked);
    }
  }
}
