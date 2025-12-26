import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageKeys {
  static const String locale = 'app_locale';
  static const String firstLaunchCompleted = 'first_launch_completed';
  static const String darkMode = 'dark_mode';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
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
    await Hive.openBox('place_cache');
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

  Future<void> remove(List<String> keys) async {
    for (final key in keys) {
      await _storage.remove(key);
    }
  }

  Future<bool> clear() => _storage.clear();
  bool containsKey(String key) => _storage.containsKey(key);
}
