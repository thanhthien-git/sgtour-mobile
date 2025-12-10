import '../models/language_option_model.dart';
import '../providers/locale_provider.dart';

const List<LanguageOptionModel> languageOptions = [
  LanguageOptionModel(
    locale: AppLocales.english,
    title: 'English',
    subtitle: 'Continue in English',
  ),
  LanguageOptionModel(
    locale: AppLocales.vietnamese,
    title: 'Tiếng Việt',
    subtitle: 'Tiếp tục với Tiếng Việt',
  ),
];
