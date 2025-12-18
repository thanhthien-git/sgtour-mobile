import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class AppLocales {
  static const Locale english = Locale('en');
  static const Locale vietnamese = Locale('vi');

  static const List<Locale> supportedLocales = [english, vietnamese];

  static const Locale defaultLocale = vietnamese;

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

class LocaleState {
  final Locale locale;
  final bool isInitialized;
  final bool isFirstLaunch;
  final bool isCompletedOnboarding;

  const LocaleState({
    required this.locale,
    required this.isInitialized,
    required this.isFirstLaunch,
    required this.isCompletedOnboarding,
  });

  factory LocaleState.initial() {
    return const LocaleState(
      locale: Locale('vi'),
      isInitialized: false,
      isFirstLaunch: true,
      isCompletedOnboarding: true,
    );
  }

  LocaleState copyWith({
    Locale? locale,
    bool? isInitialized,
    bool? isFirstLaunch,
    bool? isCompletedOnboarding,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isInitialized: isInitialized ?? this.isInitialized,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isCompletedOnboarding:
          isCompletedOnboarding ?? this.isCompletedOnboarding,
    );
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, LocaleState>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<LocaleState> {
  late final StorageService _storage;

  @override
  LocaleState build() {
    _storage = StorageService.instance;
    return LocaleState.initial();
  }

  void initialize() {
    if (state.isInitialized) return;

    final languageCode = _storage.getString(StorageKeys.locale);
    final firstLaunchCompleted =
        _storage.getBool(StorageKeys.firstLaunchCompleted) ?? false;
    final onboardingCompleted =
        _storage.getBool(StorageKeys.onboardingCompleted) ?? false;

    state = state.copyWith(
      locale: languageCode != null
          ? AppLocales.fromLanguageCode(languageCode)
          : state.locale,
      isFirstLaunch: !firstLaunchCompleted,
      isCompletedOnboarding: onboardingCompleted,
      isInitialized: true,
    );
  }

  Future<void> setLocaleFirstTime(Locale newLocale) async {
    state = state.copyWith(locale: newLocale, isFirstLaunch: false);

    await _storage.setString(StorageKeys.locale, newLocale.languageCode);
    await _storage.setBool(StorageKeys.firstLaunchCompleted, true);
  }

  Future<void> setLocale(Locale newLocale) async {
    if (state.locale == newLocale) return;

    state = state.copyWith(locale: newLocale);
    await _persistLocale(newLocale);
  }

  Future<void> toggleLocale() async {
    final newLocale = state.locale == AppLocales.english
        ? AppLocales.vietnamese
        : AppLocales.english;
    await setLocale(newLocale);
  }

  Future<void> _persistLocale(Locale locale) async {
    await _storage.setString(StorageKeys.locale, locale.languageCode);
  }
}
