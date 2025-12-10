import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Supported locales in the app
class AppLocales {
  static const Locale english = Locale('en');
  static const Locale vietnamese = Locale('vi');

  static const List<Locale> supportedLocales = [english, vietnamese];

  static const Locale defaultLocale = vietnamese;

  /// Get locale from language code
  static Locale fromLanguageCode(String? code) {
    switch (code) {
      case 'en':
        return english;
      case 'vi':
        return vietnamese;
      default:
        return defaultLocale;
    }
  }

  /// Get display name for locale
  static String getDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return locale.languageCode;
    }
  }

  /// Get native name for locale
  static String getNativeName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return locale.languageCode;
    }
  }
}

/// Provider for managing app locale with persistence
/// Uses ChangeNotifier for efficient rebuilds - only widgets that listen will rebuild
class LocaleProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  Locale _locale = AppLocales.defaultLocale;
  bool _isInitialized = false;
  bool _isFirstLaunch = true;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;
  bool get isFirstLaunch => _isFirstLaunch;

  /// Initialize locale from storage
  /// Call this once at app startup
  void initialize() {
    if (_isInitialized) return;

    final languageCode = _storage.getString(StorageKeys.locale);
    final firstLaunchCompleted =
        _storage.getBool(StorageKeys.firstLaunchCompleted) ?? false;

    _isFirstLaunch = !firstLaunchCompleted;

    if (languageCode != null) {
      _locale = AppLocales.fromLanguageCode(languageCode);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Set locale on first launch and mark first launch as completed
  Future<void> setLocaleFirstTime(Locale newLocale) async {
    _locale = newLocale;
    _isFirstLaunch = false;
    notifyListeners();

    // Persist both locale and first launch flag
    await _storage.setString(StorageKeys.locale, newLocale.languageCode);
    await _storage.setBool(StorageKeys.firstLaunchCompleted, true);
  }

  /// Change locale and persist to storage
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    _locale = newLocale;
    notifyListeners();

    // Persist in background - don't await to avoid blocking UI
    _persistLocale(newLocale);
  }

  /// Toggle between English and Vietnamese
  Future<void> toggleLocale() async {
    final newLocale = _locale == AppLocales.english
        ? AppLocales.vietnamese
        : AppLocales.english;
    await setLocale(newLocale);
  }

  /// Persist locale to storage
  Future<void> _persistLocale(Locale locale) async {
    await _storage.setString(StorageKeys.locale, locale.languageCode);
  }
}
