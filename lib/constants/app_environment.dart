/// Environment configuration for the app
class AppEnvironment {
  static const Environment environment = Environment.production;

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.sgtour.com',
  );

  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'your-api-key-here',
  );
}

enum Environment { development, staging, production }
