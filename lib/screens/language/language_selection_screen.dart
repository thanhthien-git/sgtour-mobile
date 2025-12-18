import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/decorative_circle_background.dart';

/// Data class for language option
class _LanguageOptionData {
  final Locale locale;
  final String title;
  final String subtitle;

  const _LanguageOptionData({
    required this.locale,
    required this.title,
    required this.subtitle,
  });
}

/// Available language options
const List<_LanguageOptionData> _languageOptions = [
  _LanguageOptionData(
    locale: AppLocales.english,
    title: 'English',
    subtitle: 'Continue in English',
  ),
  _LanguageOptionData(
    locale: AppLocales.vietnamese,
    title: 'Tiếng Việt',
    subtitle: 'Tiếp tục với Tiếng Việt',
  ),
];

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const DecorativeCircleBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // App Logo
                  Image.asset(
                    'assets/images/splash.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Chọn ngôn ngữ',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your language',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  ..._languageOptions.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _LanguageOption(
                        locale: option.locale,
                        title: option.title,
                        subtitle: option.subtitle,
                        onTap: () => _selectLanguage(ref, option.locale),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(WidgetRef ref, Locale locale) {
    ref.read(localeProvider.notifier).setLocaleFirstTime(locale);
  }
}

class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.locale,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Language icon
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
