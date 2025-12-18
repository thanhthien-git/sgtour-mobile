import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class ThemeState {
  final bool isDark;
  const ThemeState({required this.isDark});
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    try {
      final isDark =
          StorageService.instance.getBool(StorageKeys.darkMode) ?? false;
      return ThemeState(isDark: isDark);
    } catch (_) {
      return const ThemeState(isDark: false);
    }
  }

  void toggle() {
    final newMode = !state.isDark;
    setDarkMode(newMode);
  }

  Future<void> setDarkMode(bool isDark) async {
    if (state.isDark == isDark) return;
    state = ThemeState(isDark: isDark);
    await StorageService.instance.setBool(StorageKeys.darkMode, isDark);
  }
}
