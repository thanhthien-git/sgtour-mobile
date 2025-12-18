import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? prefixIcon;
  final String? hintText;
  final double? width;
  final double? height;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.prefixIcon,
    this.hintText,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldHeight = height ?? 56;

    final bgColor = isDark ? AppColors.surfaceDark : AppColors.inputBackground;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final hintColor = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;
    final dropdownBgColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Container(
      height: fieldHeight,
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      // Căn giữa toàn bộ nội dung trong Container
      alignment: Alignment.center,
      child: ButtonTheme(
        // alignedDropdown: true giúp dropdown full width nhưng đôi khi gây lệch nếu có prefixIcon
        // Nếu layout vẫn lệch, bạn có thể thử bỏ dòng này đi.
        alignedDropdown: true,
        child: DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: dropdownBgColor,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          menuMaxHeight: 300,

          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            size: 24,
          ),

          style: AppTextStyles.body1.copyWith(
            color: textColor,
            overflow: TextOverflow.ellipsis,
            // QUAN TRỌNG: Bỏ height cố định để text tự căn giữa theo line-height mặc định
            // height: 1.2,
          ),

          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,

            prefixIcon: prefixIcon,
            // Giữ icon ổn định tại vị trí, tránh bị xê dịch
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48, // Đảm bảo độ rộng tối thiểu cho vùng click của icon
              minHeight: 24,
            ),

            hintText: hintText,
            hintStyle: AppTextStyles.body1.copyWith(color: hintColor),

            isDense: true,
            // Padding:
            // - Left: 0 vì prefixIcon đã có minWidth (tự tạo khoảng cách).
            // - Right: 16 để cách mũi tên ra.
            // - Vertical: 0 để Container tự căn giữa.
            contentPadding: const EdgeInsets.only(right: 16),
          ),
        ),
      ),
    );
  }
}
