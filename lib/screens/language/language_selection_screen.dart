import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtourcus/l10n/generated/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/decorative_circle_background.dart';

Future<AppLocalizations> _getLocalizationForLocale(Locale locale) async {
  return AppLocalizations.delegate.load(locale);
}

class _LanguageOptionData {
  final Locale locale;
  final String nativeName;
  final String englishName;

  const _LanguageOptionData({
    required this.locale,
    required this.nativeName,
    required this.englishName,
  });
}

const List<_LanguageOptionData> _languageOptions = [
  _LanguageOptionData(
    locale: AppLocales.vietnamese,
    nativeName: 'Tiếng Việt',
    englishName: 'Vietnamese',
  ),
  _LanguageOptionData(
    locale: AppLocales.english,
    nativeName: 'English',
    englishName: 'English',
  ),
  _LanguageOptionData(
    locale: AppLocales.russian,
    nativeName: 'Русский',
    englishName: 'Russian',
  ),
  _LanguageOptionData(
    locale: AppLocales.chinese,
    nativeName: '中文',
    englishName: 'Chinese',
  ),
  _LanguageOptionData(
    locale: AppLocales.korean,
    nativeName: '한국어',
    englishName: 'Korean',
  ),
  _LanguageOptionData(
    locale: AppLocales.french,
    nativeName: 'Français',
    englishName: 'French',
  ),
  _LanguageOptionData(
    locale: AppLocales.japanese,
    nativeName: '日本語',
    englishName: 'Japanese',
  ),
  _LanguageOptionData(
    locale: AppLocales.hindi,
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
  ),
];

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  late Locale _selectedLocale;
  late TextEditingController _searchController;
  late Future<AppLocalizations> _selectedLocalization;

  @override
  void initState() {
    super.initState();
    _selectedLocale = ref.read(localeProvider).locale;
    _searchController = TextEditingController();
    _selectedLocalization = _getLocalizationForLocale(_selectedLocale);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSelectedLocale(Locale locale) {
    setState(() {
      _selectedLocale = locale;
      _selectedLocalization = _getLocalizationForLocale(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = _languageOptions
        .where(
          (lang) =>
              lang.nativeName.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ) ||
              lang.englishName.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
        )
        .toList();

    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const DecorativeCircleBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    children: [
                      // App Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        'Chọn ngôn ngữ',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your language',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredLanguages.length,
                    itemBuilder: (context, index) {
                      final option = filteredLanguages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LanguageListTile(
                          option: option,
                          isSelected: option.locale == _selectedLocale,
                          onTap: () {
                            _updateSelectedLocale(option.locale);
                          },
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FutureBuilder<AppLocalizations>(
                      future: _selectedLocalization,
                      builder: (context, snapshot) {
                        final buttonText =
                            snapshot.data?.onboarding_getStarted ??
                            localizations?.onboarding_getStarted ??
                            'Continue';
                        return ElevatedButton(
                          onPressed: () => _selectLanguage(ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            buttonText,
                            style: AppTextStyles.subtitle2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(WidgetRef ref) {
    ref.read(localeProvider.notifier).setLocaleFirstTime(_selectedLocale);
  }
}

class _LanguageListTile extends StatelessWidget {
  final _LanguageOptionData option;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageListTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.nativeName,
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppColors.primary, size: 24)
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
