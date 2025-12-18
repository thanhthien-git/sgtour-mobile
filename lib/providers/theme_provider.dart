import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class ThemeState {
  final bool isDark;

  const ThemeState({required this.isDark});

  factory ThemeState.initial() {
    return const ThemeState(isDark: false);
  }

  ThemeState copyWith({bool? isDark}) {
    return ThemeState(isDark: isDark ?? this.isDark);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeState> {
  late final StorageService _storage;

  @override
  ThemeState build() {
    _storage = StorageService.instance;
    return ThemeState.initial();
  }

  void initialize() {
    final isDark = _storage.getBool(StorageKeys.darkMode) ?? false;
    state = state.copyWith(isDark: isDark);
  }

  void toggle() {
    setDarkMode(!state.isDark);
  }

  void setDarkMode(bool isDark) {
    if (state.isDark == isDark) return;
    state = state.copyWith(isDark: isDark);
    _persist();
  }

  Future<void> _persist() async {
    await _storage.setBool(StorageKeys.darkMode, state.isDark);
  }
}
