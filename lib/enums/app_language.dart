enum AppLanguage {
  vi('vi', 'Tiếng Việt', '🇻🇳'),
  en('en', 'English', '🇺🇸'),
  ja('ja', '日本語', '🇯🇵'),
  zh('zh', '中文', '🇨🇳'),
  ko('ko', '한국어', '🇰🇷'),
  fr('fr', 'Français', '🇫🇷'),
  de('de', 'Deutsch', '🇩🇪'),
  es('es', 'Español', '🇪🇸'),
  th('th', 'ไทย', '🇹🇭'),
  ru('ru', 'Русский', '🇷🇺');

  final String code;
  final String name;
  final String flag;

  const AppLanguage(this.code, this.name, this.flag);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppLanguage.en,
    );
  }
}
