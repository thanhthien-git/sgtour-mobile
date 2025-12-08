# SGTour Flutter App - Project Structure

This is a production-ready Flutter app structure following best practices for both iOS and Android development.

## 📁 Project Structure

```
lib/
├── config/                          # App Configuration & Theme
│   ├── app_config.dart             # App settings and constants
│   ├── app_colors.dart             # Color palette (customize here)
│   ├── app_text_styles.dart        # Typography styles
│   ├── app_assets.dart             # Asset paths (images, icons)
│   └── app_theme.dart              # Material themes (light/dark)
│
├── api/                            # API & Network Layer
│   ├── api_service.dart            # HTTP client (Dio)
│   └── api_response.dart           # Generic API response model
│
├── models/                         # Data Models
│   └── tour_model.dart             # Example model with JSON serialization
│
├── screens/                        # UI Screens
│   ├── home/
│   ├── details/
│   ├── profile/
│   └── README.md
│
├── widgets/                        # Reusable UI Components
│   ├── custom_app_bar.dart
│   ├── state_builder.dart
│   └── ...
│
├── providers/                      # State Management
│   └── theme_provider.dart         # Example provider
│
├── services/                       # Business Logic Services
│   ├── auth_service.dart
│   ├── tour_service.dart
│   └── ...
│
├── utils/                          # Utility Functions
│   ├── validators.dart
│   ├── formatters.dart
│   ├── logger.dart
│   └── ...
│
├── constants/                      # App Constants
│   ├── app_environment.dart        # Environment configuration
│   └── constants.dart              # General constants
│
└── main.dart                       # App entry point

assets/
├── images/                         # App images & logos
│   ├── app_logo.png
│   ├── splash_logo.png
│   └── ...
├── icons/                          # SVG icons
│   ├── home.svg
│   ├── search.svg
│   └── ...
└── fonts/                          # Custom fonts
    └── ...
```

## 🎨 Customization Guide

### Change App Colors
Edit `lib/config/app_colors.dart` - modify the color constants:
```dart
static const Color primary = Color(0xFF1976D2); // Change to your brand color
```

### Change Fonts & Typography
Edit `lib/config/app_text_styles.dart`:
```dart
static const String fontFamily = 'Inter'; // Change to your font
```

### Change App Logo & Images
Edit `lib/config/app_assets.dart`:
```dart
static const String appLogo = 'assets/images/app_logo.png';
```
Then add your images to `assets/images/` folder.

### Change App Theme
Edit `lib/config/app_theme.dart` to customize Material Design theme.

### Change App Configuration
Edit `lib/config/app_config.dart` for app name, API endpoints, etc.

## 🔌 Adding Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  riverpod: ^2.0.0  # or use riverpod for more advanced state management
  
  # API & Networking
  dio: ^5.0.0
  http: ^1.0.0
  
  # JSON Serialization
  json_serializable: ^6.0.0
  freezed_class_name: ^2.0.0
  
  # Database
  hive: ^2.0.0
  sqflite: ^2.0.0
  
  # Local Storage
  shared_preferences: ^2.0.0
  
  # UI & Design
  flutter_svg: ^2.0.0
  cached_network_image: ^3.0.0
  
  # Utilities
  intl: ^0.17.0
  logger: ^1.3.0
  connectivity_plus: ^3.0.0
  
  # Testing
  mockito: ^5.0.0
  bloc_test: ^9.0.0
```

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles:

1. **Presentation Layer** (Screens, Widgets)
   - Handles UI and user interactions
   - Uses state management (Provider, Riverpod, BLoC)

2. **Domain Layer** (Models, Services)
   - Business logic
   - Independent of frameworks

3. **Data Layer** (API, Local Storage)
   - Data sources and repositories
   - API calls and database operations

## 📱 iOS & Android Setup

### iOS
```bash
cd ios
pod install
```

### Android
No additional setup needed if using Gradle.

## 🚀 Running the App

```bash
# Run on emulator/device
flutter run

# Run with specific device
flutter run -d <device_id>

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

## 📝 Code Style Guidelines

1. **Naming Conventions**
   - Classes: PascalCase (e.g., `TourModel`)
   - Variables: camelCase (e.g., `tourList`)
   - Constants: camelCase (e.g., `appName`)
   - Private: prefix with underscore (e.g., `_privateMethod`)

2. **File Organization**
   - One public class per file
   - Related code in same file (except large classes)
   - Logical import grouping

3. **Comments**
   - Document public APIs with documentation comments (///)
   - Use meaningful variable names instead of cryptic comments

## 🔐 Security Best Practices

1. **API Keys**: Never commit API keys, use environment variables
2. **Sensitive Data**: Store in Keychain (iOS) or Keystore (Android)
3. **HTTPS**: Always use HTTPS for API calls
4. **Input Validation**: Validate all user inputs

## 📊 State Management Options

### Provider (Recommended for beginners)
- Simple and easy to understand
- Good for small to medium apps

### Riverpod (Recommended for large apps)
- More powerful than Provider
- Better type safety

### BLoC
- Perfect for complex business logic
- Steep learning curve

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/models/tour_model_test.dart

# Generate coverage
flutter test --coverage
```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design](https://material.io)
- [Dart Best Practices](https://dart.dev/guides/language/effective-dart)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture)

## 💡 Tips

- Use `flutter analyze` to check code quality
- Use `dart format` to format code
- Use `flutter pub get` to update dependencies
- Keep models and services separate from UI

---

**Ready to build amazing apps! 🚀**
