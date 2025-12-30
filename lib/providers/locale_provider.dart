import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/file/storage_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AppLocales {
  static const Locale english = Locale('en');
  static const Locale vietnamese = Locale('vi');
  static const Locale russian = Locale('ru');
  static const Locale chinese = Locale('zh');
  static const Locale korean = Locale('ko');
  static const Locale french = Locale('fr');
  static const Locale japanese = Locale('ja');
  static const Locale hindi = Locale('hi');

  static const List<Locale> supportedLocales = [
    english,
    vietnamese,
    russian,
    chinese,
    korean,
    french,
    japanese,
    hindi,
  ];

  static const Locale defaultLocale = vietnamese;

  static Locale fromLanguageCode(String? code) {
    switch (code) {
      case 'en':
        return english;
      case 'vi':
        return vietnamese;
      case 'ru':
        return russian;
      case 'zh':
        return chinese;
      case 'ko':
        return korean;
      case 'fr':
        return french;
      case 'ja':
        return japanese;
      case 'hi':
        return hindi;
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
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ko':
        return '한국어';
      case 'fr':
        return 'Français';
      case 'ja':
        return '日本語';
      case 'hi':
        return 'हिन्दी';
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
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ko':
        return '한국어';
      case 'fr':
        return 'Français';
      case 'ja':
        return '日本語';
      case 'hi':
        return 'हिन्दी';
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
  final String? speechLocaleId;

  const LocaleState({
    required this.locale,
    required this.isInitialized,
    required this.isFirstLaunch,
    required this.isCompletedOnboarding,
    this.speechLocaleId,
  });

  factory LocaleState.initial() {
    return const LocaleState(
      locale: Locale('vi'),
      isInitialized: false,
      isFirstLaunch: true,
      isCompletedOnboarding: false,
    );
  }

  LocaleState copyWith({
    Locale? locale,
    bool? isInitialized,
    bool? isFirstLaunch,
    bool? isCompletedOnboarding,
    String? speechLocaleId,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isInitialized: isInitialized ?? this.isInitialized,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isCompletedOnboarding:
          isCompletedOnboarding ?? this.isCompletedOnboarding,
      speechLocaleId: speechLocaleId ?? this.speechLocaleId,
    );
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, LocaleState>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<LocaleState> {
  late final StorageService _storage;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  LocaleState build() {
    _storage = StorageService.instance;
    Future.microtask(() => initialize());
    return LocaleState.initial();
  }

  void initialize() async {
    if (state.isInitialized) return;

    final languageCode = _storage.getString(StorageKeys.locale);
    final firstLaunchCompleted =
        _storage.getBool(StorageKeys.firstLaunchCompleted) ?? false;
    final onboardingCompleted =
        _storage.getBool(StorageKeys.onboardingCompleted) ?? false;
    final initialLocale = languageCode != null
        ? AppLocales.fromLanguageCode(languageCode)
        : state.locale;

    state = state.copyWith(
      locale: initialLocale,
      isFirstLaunch: !firstLaunchCompleted,
      isCompletedOnboarding: onboardingCompleted,
      isInitialized: true,
    );

    _syncSpeechLocale(initialLocale);
  }

  Future<void> _syncSpeechLocale(Locale targetAppLocale) async {
    try {
      bool available = await _speech.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );

      if (!available) {
        state = state.copyWith(speechLocaleId: targetAppLocale.languageCode);
        return;
      }

      var systemLocales = await _speech.locales();

      if (systemLocales.isEmpty) {
        state = state.copyWith(speechLocaleId: targetAppLocale.languageCode);
        return;
      }

      var bestMatch = systemLocales.firstWhere(
        (l) => l.localeId.toLowerCase().startsWith(
          targetAppLocale.languageCode.toLowerCase(),
        ),

        orElse: () {
          return systemLocales.first;
        },
      );

      state = state.copyWith(speechLocaleId: bestMatch.localeId);
    } catch (e) {
      print("Error syncing speech locale: $e");
      state = state.copyWith(speechLocaleId: targetAppLocale.languageCode);
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isCompletedOnboarding: true);
    await _storage.setBool(StorageKeys.onboardingCompleted, true);
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
