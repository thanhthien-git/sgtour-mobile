import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Provider for managing app theme with persistence
class ThemeProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  bool _isDarkMode = false;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;

  /// Initialize theme from storage
  /// Call this once at app startup
  void initialize() {
    if (_isInitialized) return;

    _isDarkMode = _storage.getBool(StorageKeys.darkMode) ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _persistTheme();
  }

  void setDarkMode(bool isDark) {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;
    notifyListeners();
    _persistTheme();
  }

  Future<void> _persistTheme() async {
    await _storage.setBool(StorageKeys.darkMode, _isDarkMode);
  }
}
