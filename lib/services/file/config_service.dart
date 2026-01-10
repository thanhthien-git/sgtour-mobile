import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static ConfigService? _instance;

  final String _apiBaseUrl;
  final String _googleWebClientId;

  ConfigService._(this._apiBaseUrl, this._googleWebClientId);

  static Future<void> initialize() async {
    if (_instance != null) return;
    await dotenv.load(fileName: ".env");
    String api = '';
    String google = '';
    try {
      api = dotenv.get('API_BASE_URL', fallback: '');
      google = dotenv.get('GOOGLE_WEB_CLIENT_ID', fallback: '');
    } catch (e) {}

    _instance = ConfigService._(api, google);
  }

  static ConfigService get instance {
    if (_instance == null) {
      throw StateError(
        'ConfigService not initialized. Call ConfigService.initialize() first.',
      );
    }
    return _instance!;
  }

  String get apiBaseUrl => _apiBaseUrl;
  String get googleWebClientId => _googleWebClientId;
}
