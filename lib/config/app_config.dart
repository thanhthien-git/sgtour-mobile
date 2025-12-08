/// Central configuration for the app
/// All customizable app settings should be defined here
class AppConfig {
  // App Information
  static const String appName = 'SGTour';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.sgtour.com';
  static const int apiTimeout = 30; // seconds
  static const int retryAttempts = 3;

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableDebugLogging = false;

  // Pagination
  static const int pageSize = 20;

  // Cache Duration (in minutes)
  static const int cacheDuration = 60;

  // Social Links
  static const String websiteUrl = 'https://www.sgtour.com';
  static const String supportEmail = 'support@sgtour.com';
}
