import '../models/language_option_model.dart';
import '../providers/locale_provider.dart';

const List<LanguageOptionModel> languageOptions = [
  LanguageOptionModel(
    locale: AppLocales.english,
    title: 'English',
    subtitle: 'English',
  ),
  LanguageOptionModel(
    locale: AppLocales.vietnamese,
    title: 'Tiếng Việt',
    subtitle: 'Vietnamese',
  ),
  LanguageOptionModel(
    locale: AppLocales.russian,
    title: 'Русский',
    subtitle: 'Russian',
  ),
  LanguageOptionModel(
    locale: AppLocales.chinese,
    title: '中文',
    subtitle: 'Chinese',
  ),
  LanguageOptionModel(
    locale: AppLocales.korean,
    title: '한국어',
    subtitle: 'Korean',
  ),
  LanguageOptionModel(
    locale: AppLocales.french,
    title: 'Français',
    subtitle: 'French',
  ),
  LanguageOptionModel(
    locale: AppLocales.japanese,
    title: '日本語',
    subtitle: 'Japanese',
  ),
  LanguageOptionModel(
    locale: AppLocales.hindi,
    title: 'हिन्दी',
    subtitle: 'Hindi',
  ),
];
