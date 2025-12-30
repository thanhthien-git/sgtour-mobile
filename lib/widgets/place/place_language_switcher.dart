import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../enums/place_language.dart';

class PlaceLanguageSwitcher extends StatelessWidget {
  final PlaceLanguage selectedLanguage;
  final List<PlaceLanguage> availableLanguages;
  final ValueChanged<PlaceLanguage> onLanguageChanged;

  const PlaceLanguageSwitcher({
    super.key,
    required this.selectedLanguage,
    required this.availableLanguages,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<PlaceLanguage>(
      initialValue: selectedLanguage,
      onSelected: onLanguageChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 16),
            const SizedBox(width: 6),
            Text(
              selectedLanguage.displayName,
              style: AppTextStyles.subtitle2.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return availableLanguages.map((language) {
          final isSelected = language == selectedLanguage;
          return PopupMenuItem<PlaceLanguage>(
            value: language,
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check, size: 18, color: AppColors.primary)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(
                  language.displayName,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
