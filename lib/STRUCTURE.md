/// File structure documentation
/*
FOLDER STRUCTURE GUIDE:

lib/
├── api/                 - API integration and HTTP requests
│   ├── api_service.dart         - Main HTTP client
│   └── api_response.dart        - Generic response wrapper
│
├── config/              - App-wide configuration
│   ├── app_config.dart          - App settings
│   ├── app_colors.dart          - ✏️ CUSTOMIZE: App colors & branding
│   ├── app_text_styles.dart     - ✏️ CUSTOMIZE: Typography
│   ├── app_assets.dart          - ✏️ CUSTOMIZE: Asset paths
│   └── app_theme.dart           - ✏️ CUSTOMIZE: Material theme
│
├── constants/           - Static constants
│   ├── app_environment.dart     - Environment variables
│   └── constants.dart           - App-wide constants
│
├── models/              - Data models
│   └── tour_model.dart          - Example model
│
├── providers/           - State management
│   └── theme_provider.dart      - Example provider
│
├── screens/             - UI Screens (organize by feature)
│   ├── home/
│   ├── details/
│   └── profile/
│
├── services/            - Business logic layer
│   ├── auth_service.dart
│   └── tour_service.dart
│
├── utils/               - Utility functions
│   ├── validators.dart          - Input validation
│   ├── formatters.dart          - Data formatting
│   └── logger.dart              - Logging utilities
│
├── widgets/             - Reusable UI components
│   ├── custom_app_bar.dart
│   └── state_builder.dart
│
└── main.dart            - App entry point

assets/
├── images/              - ✏️ CUSTOMIZE: Add your images
│   ├── app_logo.png
│   └── splash_logo.png
├── icons/               - ✏️ CUSTOMIZE: Add your SVG icons
│   ├── home.svg
│   └── search.svg
└── fonts/               - ✏️ CUSTOMIZE: Add custom fonts

═══════════════════════════════════════════════════════════════════

CUSTOMIZATION CHECKLIST:

1. COLORS & BRANDING
   - Edit lib/config/app_colors.dart
   - Change primary, secondary, tertiary colors
   - Add your images to assets/images/
   - Update app_logo.png with your logo

2. TYPOGRAPHY
   - Edit lib/config/app_text_styles.dart
   - Change fontFamily if using custom fonts
   - Add fonts to assets/fonts/ and pubspec.yaml

3. THEME
   - Edit lib/config/app_theme.dart
   - Customize button styles, shadows, radius
   - Adjust spacing and padding

4. CONFIGURATION
   - Edit lib/config/app_config.dart
   - Set your app name, API endpoint, version

5. ASSETS
   - Edit lib/config/app_assets.dart
   - Add your image and icon paths

═══════════════════════════════════════════════════════════════════

BEST PRACTICES:

✅ Separation of Concerns
   - Keep UI in screens/ and widgets/
   - Business logic in services/
   - Data handling in models/ and api/

✅ Reusability
   - Extract common widgets to widgets/
   - Create utility functions in utils/
   - Use providers for state management

✅ Consistency
   - Always use AppColors for colors
   - Always use AppTextStyles for text
   - Always use AppAssets for images

✅ Naming Conventions
   - Classes: PascalCase (TourModel)
   - Variables: camelCase (tourList)
   - Constants: camelCase (appName)
   - Private: _underscore (_privateVar)

✅ Organization
   - Group related code in folders
   - One main class per file
   - Keep files focused and small

═══════════════════════════════════════════════════════════════════
*/
