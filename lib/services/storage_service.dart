import 'package:shared_preferences/shared_preferences.dart';

/// Storage keys - all keys must be defined here
abstract class StorageKeys {
  static const String locale = 'app_locale';
  static const String firstLaunchCompleted = 'first_launch_completed';
  static const String darkMode = 'dark_mode';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String authToken = 'auth_token';
}

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _storage {
    if (_prefs == null) {
      throw StateError(
        'StorageService not initialized. Call StorageService.initialize() first.',
      );
    }
    return _prefs!;
  }

  String? getString(String key) => _storage.getString(key);
  bool? getBool(String key) => _storage.getBool(key);
  int? getInt(String key) => _storage.getInt(key);
  double? getDouble(String key) => _storage.getDouble(key);
  List<String>? getStringList(String key) => _storage.getStringList(key);

  Future<bool> setString(String key, String value) =>
      _storage.setString(key, value);
  Future<bool> setBool(String key, bool value) => _storage.setBool(key, value);
  Future<bool> setInt(String key, int value) => _storage.setInt(key, value);
  Future<bool> setDouble(String key, double value) =>
      _storage.setDouble(key, value);
  Future<bool> setStringList(String key, List<String> value) =>
      _storage.setStringList(key, value);

  Future<bool> remove(String key) => _storage.remove(key);
  Future<bool> clear() => _storage.clear();
  bool containsKey(String key) => _storage.containsKey(key);
}
