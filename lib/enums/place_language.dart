enum PlaceLanguage {
  vi('vi', 'Tiếng Việt'),
  en('en', 'English'),
  ja('ja', '日本語'),
  zh('zh', '中文'),
  ko('ko', '한국어'),
  fr('fr', 'Français'),
  de('de', 'Deutsch'),
  es('es', 'Español'),
  th('th', 'ภาษาไทย'),
  ru('ru', 'Русский');

  final String code;
  final String displayName;

  const PlaceLanguage(this.code, this.displayName);

  static PlaceLanguage fromCode(String code) {
    return PlaceLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => PlaceLanguage.en,
    );
  }
}
