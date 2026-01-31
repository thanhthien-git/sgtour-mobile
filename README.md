# SGTour - Flutter Mobile App 🚀

**Production-Ready Flutter Structure for iOS & Android**

---

## 📊 Project Overview

A complete, scalable Flutter application structure designed for travel/tourism apps like SGTour. Built with clean architecture principles and Material Design 3.

### 🎯 What's Included

✅ **Production Structure** - Organized folders for all app components
✅ **Material Design 3** - Modern, beautiful UI framework
✅ **Configuration System** - Centralized settings for colors, fonts, images
✅ **API Integration** - Ready-to-use HTTP client with interceptors
✅ **Type Safety** - Full Dart null safety
✅ **Best Practices** - Clean architecture & SOLID principles
✅ **iOS & Android** - Cross-platform compatibility

---

## 📁 Project Structure

```
sgtourcus/
│
├── lib/
│   ├── api/                          # API & Networking
│   │   ├── api_service.dart          # HTTP client (Dio)
│   │   └── api_response.dart         # Response wrapper
│   │
│   ├── config/                       # ⚙️ CUSTOMIZE HERE
│   │   ├── app_config.dart           # App settings
│   │   ├── app_colors.dart           # 🎨 Brand colors
│   │   ├── app_text_styles.dart      # 📝 Typography
│   │   ├── app_assets.dart           # 🖼️ Asset paths
│   │   └── app_theme.dart            # Theme setup
│   │
│   ├── constants/                    # App constants
│   │   ├── app_environment.dart      # Environment config
│   │   └── constants.dart            # General constants
│   │
│   ├── models/                       # Data Models
│   │   └── tour_model.dart           # Example model
│   │
│   ├── screens/                      # UI Screens
│   │   └── README.md                 # Screen templates
│   │
│   ├── widgets/                      # Reusable Components
│   │   ├── custom_app_bar.dart
│   │   └── state_builder.dart
│   │
│   ├── providers/                    # State Management
│   │   └── theme_provider.dart       # Example provider
│   │
│   ├── services/                     # Business Logic
│   │   └── (create your services here)
│   │
│   ├── utils/                        # Utilities
│   │   ├── validators.dart           # Input validation
│   │   ├── formatters.dart           # Data formatting
│   │   └── logger.dart               # Logging
│   │
│   ├── STRUCTURE.md                  # Structure guide
│   └── main.dart                     # App entry point
│
├── assets/
│   ├── images/                       # 🖼️ Add logos & images
│   ├── icons/                        # 🎯 Add SVG icons
│   └── fonts/                        # 🔤 Add custom fonts
│
├── ios/                              # iOS native code
├── android/                          # Android native code
│
├── QUICK_START.md                    # ⭐ Start here
├── PROJECT_STRUCTURE.md              # Detailed structure
├── UI_KIT_GUIDE.md                   # UI kit recommendations
├── SETUP_GUIDE.md                    # Setup & dependencies
└── README.md                         # This file
```

---

## 🎨 Material Design 3 - The Recommended UI Kit

### Why Material Design 3?

| Feature | Material Design 3 |
|---------|-------------------|
| Official Support | ✅ Google's official design system |
| Easy Customization | ✅ Just change colors and fonts |
| Professional Look | ✅ Modern and polished |
| Dark Mode | ✅ Built-in support |
| Responsive | ✅ Works on all screen sizes |
| Documentation | ✅ Excellent community resources |
| Learning Curve | ✅ Beginner-friendly |

### Already Configured ✨

Material Design 3 is already set up in this project! Just customize:

1. **Colors** → `lib/config/app_colors.dart`
2. **Fonts** → `lib/config/app_text_styles.dart`
3. **Theme** → `lib/config/app_theme.dart`

---

## 🎨 Customization - 4 Easy Steps

### Step 1: Change Brand Colors

**File:** `lib/config/app_colors.dart`

```dart
// Find these lines and change the color codes:
static const Color primary = Color(0xFF1976D2);      // 👈 Change this
static const Color secondary = Color(0xFFFFA726);    // 👈 Change this
static const Color tertiary = Color(0xFF66BB6A);     // 👈 Change this
```

Use [Material Color Tool](https://material-foundation.github.io/material-theme-builder/) to generate colors.

### Step 2: Add Your Logo

**Files to add:**
```
assets/images/
├── app_logo.png           # Your main logo
├── splash_logo.png        # Splash screen logo
└── app_logo_white.png     # White version for dark mode
```

**Update:** `lib/config/app_assets.dart`

### Step 3: Change Typography (Optional)

**File:** `lib/config/app_text_styles.dart`

```dart
static const String fontFamily = 'YourFont';  // Change to your font
```

**Add font files:**
```
assets/fonts/
├── yourfont-regular.ttf
└── yourfont-bold.ttf
```

### Step 4: Update Configuration

**File:** `lib/config/app_config.dart`

```dart
static const String appName = 'SGTour';                    // Your app name
static const String baseUrl = 'https://api.sgtour.com';  // Your API
static const String appVersion = '1.0.0';                // Version
```

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
# Open pubspec.yaml and add these:
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0              # State management
  dio: ^5.0.0                   # HTTP client
  cached_network_image: ^3.0.0
  flutter_svg: ^2.0.0

# Run
flutter pub get
```

### 2. Create First Screen

```dart
// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('SGTour', style: AppTextStyles.heading4),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text(
          'Welcome to SGTour!',
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}
```

### 3. Run the App

```bash
flutter run
```

---

## 💡 Key Files to Customize

| File | Purpose | Action |
|------|---------|--------|
| `app_colors.dart` | Brand colors | Change color hex codes |
| `app_assets.dart` | Image paths | Add your logo paths |
| `app_config.dart` | App settings | Set API URL, app name |
| `app_text_styles.dart` | Fonts | Change font family |
| `app_theme.dart` | Theme | Customize button styles |

---

## 📚 Usage Examples

### Using Colors

```dart
// ✅ Good - Use AppColors
Container(
  color: AppColors.primary,
  child: Text('Hello', style: TextStyle(color: AppColors.textPrimary)),
)

// ❌ Bad - Hardcoded colors
Container(
  color: Color(0xFF1976D2),
  child: Text('Hello', style: TextStyle(color: Color(0xFF212121))),
)
```

### Using Text Styles

```dart
// ✅ Good - Use AppTextStyles
Text('Welcome', style: AppTextStyles.heading2)
Text('Subtitle', style: AppTextStyles.body1)

// ❌ Bad - Hardcoded styles
Text('Welcome', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))
```

### Using Assets

```dart
// ✅ Good - Use AppAssets
Image.asset(AppAssets.appLogo)
SvgPicture.asset(AppAssets.iconHome)

// ❌ Bad - Hardcoded paths
Image.asset('assets/images/app_logo.png')
```

---

## 🔌 Available Utilities

### Validators
```dart
import 'package:sgtour/utils/validators.dart';

// Email validation
String? error = Validators.validateEmail('email@example.com');

// Password validation
String? error = Validators.validatePassword('Password123!');

// Phone validation
String? error = Validators.validatePhone('1234567890');
```

### Formatters
```dart
import 'package:sgtour/utils/formatters.dart';

// Format currency
String price = Formatters.formatCurrency(99.99);  // $99.99

// Format date
String date = Formatters.formatDate(DateTime.now());  // Jan 01, 2024

// Format duration
String duration = Formatters.formatDuration(Duration(hours: 2, minutes: 30));  // 2h 30m
```

### Logger
```dart
import 'package:sgtour/utils/logger.dart';

AppLogger.log('Debug message');
AppLogger.success('Operation successful');
AppLogger.warning('Warning message');
AppLogger.error('Error occurred', exception);
```

---

## 🏗️ Architecture

```
Presentation Layer
├── Screens
├── Widgets
└── Providers (State Management)
        ↓
    Domain Layer
    ├── Models
    └── Services
        ↓
    Data Layer
    ├── API Service
    ├── Local Storage
    └── Database
```

---

## 📱 Platform-Specific Setup

### iOS
```bash
cd ios
pod install
cd ..
```

### Android
No additional setup needed. Gradle handles everything.

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/models/tour_model_test.dart

# Generate coverage
flutter test --coverage
```

---

## 🔒 Security

✅ **API Keys** - Use environment variables
```bash
flutter run --dart-define=API_KEY=your_key_here
```

✅ **Sensitive Data** - Store in Keychain (iOS) / Keystore (Android)

✅ **HTTPS** - Always use encrypted connections

✅ **Input Validation** - Use Validators class for all user input

---

## 📊 State Management Options

### Recommended: Provider
```dart
// lib/providers/tour_provider.dart
class TourProvider extends ChangeNotifier {
  List<Tour> _tours = [];
  
  List<Tour> get tours => _tours;
  
  void addTour(Tour tour) {
    _tours.add(tour);
    notifyListeners();
  }
}

// Usage in widget
Consumer<TourProvider>(
  builder: (context, provider, child) {
    return ListView(
      children: provider.tours.map((tour) => TourCard(tour: tour)).toList(),
    );
  },
)
```

---

## 📖 Documentation Files

- **QUICK_START.md** - Quick setup guide (start here!)
- **PROJECT_STRUCTURE.md** - Detailed folder structure
- **UI_KIT_GUIDE.md** - Material Design 3 guide
- **SETUP_GUIDE.md** - Dependencies and configuration
- **lib/STRUCTURE.md** - Customization checklist

---

## ❓ Common Questions

**Q: How do I add a new page?**
A: Create a folder in `lib/screens/page_name/` with `page_name_screen.dart`

**Q: Where do I put API calls?**
A: In `lib/services/` - create a service class for each feature

**Q: How do I change the app color?**
A: Edit `static const Color primary` in `lib/config/app_colors.dart`

**Q: How do I add custom fonts?**
A: Add TTF files to `assets/fonts/` and update `pubspec.yaml`

**Q: What state management should I use?**
A: Provider (recommended) or Riverpod for larger apps

---

## 🎯 Next Steps

1. ✅ Customize colors in `lib/config/app_colors.dart`
2. ✅ Add your logo to `assets/images/`
3. ✅ Update API URL in `lib/config/app_config.dart`
4. ✅ Run `flutter pub get`
5. ✅ Create your first screen in `lib/screens/`
6. ✅ Set up state management with Provider
7. ✅ Connect API services
8. ✅ Build and launch! 🚀

---

## 🤝 Contributing

This is your project! Feel free to:
- Add new screens and widgets
- Create new services
- Add more utilities
- Implement features

---

## 📞 Support Resources

- [Flutter Documentation](https://flutter.dev)
- [Material Design 3](https://m3.material.io)
- [Dart Language Guide](https://dart.dev/guides)
- [Provider Package Docs](https://pub.dev/packages/provider)
- [Dio HTTP Client](https://pub.dev/packages/dio)

---

## 📝 License

This project structure is provided as-is for educational and commercial use.

---

## 🎉 You're All Set!

Your production-ready Flutter app structure is ready to go. 

**Happy coding! 🚀**

---

### File Count Summary
- **Configuration Files:** 5
- **API Layer Files:** 2
- **Data Models:** 1
- **UI Components:** 2
- **Utilities:** 3
- **Documentation:** 4
- **Directories:** 10

**Total:** 18 files + 10 organized directories ready for development

---

*Created with ❤️ for Flutter developers*
