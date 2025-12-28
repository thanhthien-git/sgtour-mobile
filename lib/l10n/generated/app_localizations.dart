import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'SGTour'**
  String get appName;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get common_or;

  /// No description provided for @common_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get common_other;

  /// No description provided for @onboarding_title1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SGTour'**
  String get onboarding_title1;

  /// No description provided for @onboarding_desc1.
  ///
  /// In en, this message translates to:
  /// **'Discover amazing places and create unforgettable travel experiences.'**
  String get onboarding_desc1;

  /// No description provided for @onboarding_title2.
  ///
  /// In en, this message translates to:
  /// **'Smart Suggestions'**
  String get onboarding_title2;

  /// No description provided for @onboarding_desc2.
  ///
  /// In en, this message translates to:
  /// **'Get personalized recommendations based on your preferences and location.'**
  String get onboarding_desc2;

  /// No description provided for @onboarding_title3.
  ///
  /// In en, this message translates to:
  /// **'Travel with AI'**
  String get onboarding_title3;

  /// No description provided for @onboarding_desc3.
  ///
  /// In en, this message translates to:
  /// **'Let our AI assistant help you plan the perfect trip.'**
  String get onboarding_desc3;

  /// No description provided for @onboarding_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_getStarted;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get auth_confirmPassword;

  /// No description provided for @auth_fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get auth_fullName;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_noAccount;

  /// No description provided for @auth_hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_hasAccount;

  /// No description provided for @auth_createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account now'**
  String get auth_createAccount;

  /// No description provided for @auth_loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login now'**
  String get auth_loginNow;

  /// No description provided for @auth_welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get auth_welcomeBack;

  /// No description provided for @auth_createAccountToStart.
  ///
  /// In en, this message translates to:
  /// **'Create an account to get started'**
  String get auth_createAccountToStart;

  /// No description provided for @auth_loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get auth_loginSuccess;

  /// No description provided for @auth_loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get auth_loginFailed;

  /// No description provided for @auth_registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get auth_registerSuccess;

  /// No description provided for @auth_registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed!'**
  String get auth_registerFailed;

  /// No description provided for @auth_loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_loginWithGoogle;

  /// No description provided for @validation_emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get validation_emailRequired;

  /// No description provided for @validation_passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get validation_passwordRequired;

  /// No description provided for @validation_passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validation_passwordMinLength;

  /// No description provided for @validation_confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password cannot be empty'**
  String get validation_confirmPasswordRequired;

  /// No description provided for @validation_passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validation_passwordMismatch;

  /// No description provided for @validation_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get validation_nameRequired;

  /// No description provided for @location_enableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable your location'**
  String get location_enableTitle;

  /// No description provided for @location_enableDesc.
  ///
  /// In en, this message translates to:
  /// **'We need access to your location to suggest nearby tourist destinations and provide the best experience.'**
  String get location_enableDesc;

  /// No description provided for @location_enableButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get location_enableButton;

  /// No description provided for @location_feature1.
  ///
  /// In en, this message translates to:
  /// **'Discover places near you'**
  String get location_feature1;

  /// No description provided for @location_feature2.
  ///
  /// In en, this message translates to:
  /// **'Get accurate directions'**
  String get location_feature2;

  /// No description provided for @location_feature3.
  ///
  /// In en, this message translates to:
  /// **'Personalized suggestions by location'**
  String get location_feature3;

  /// No description provided for @location_permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use the app'**
  String get location_permissionRequired;

  /// No description provided for @location_serviceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable location service on your device'**
  String get location_serviceDisabled;

  /// No description provided for @location_permissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get location_permissionDeniedTitle;

  /// No description provided for @location_permissionDeniedDesc.
  ///
  /// In en, this message translates to:
  /// **'You have denied location permission. Please go to Settings to grant permission.'**
  String get location_permissionDeniedDesc;

  /// No description provided for @location_openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get location_openSettings;

  /// No description provided for @logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_confirm;

  /// No description provided for @home_exploreNearby.
  ///
  /// In en, this message translates to:
  /// **'Explore places near you'**
  String get home_exploreNearby;

  /// No description provided for @home_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get home_categories;

  /// No description provided for @home_seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get home_seeAll;

  /// No description provided for @category_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get category_food;

  /// No description provided for @category_culture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get category_culture;

  /// No description provided for @category_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get category_shopping;

  /// No description provided for @category_entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get category_entertainment;

  /// No description provided for @nav_explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get nav_explore;

  /// No description provided for @nav_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get nav_map;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @map_title.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map_title;

  /// No description provided for @map_comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get map_comingSoon;

  /// No description provided for @map_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for a place...'**
  String get map_search_hint;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get profile_comingSoon;

  /// No description provided for @profile_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profile_name;

  /// No description provided for @profile_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profile_email;

  /// No description provided for @profile_changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profile_changePassword;

  /// No description provided for @profile_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profile_gender;

  /// No description provided for @profile_genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profile_genderMale;

  /// No description provided for @profile_genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profile_genderFemale;

  /// No description provided for @profile_genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profile_genderOther;

  /// No description provided for @profile_birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get profile_birthDate;

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profile_phone;

  /// No description provided for @profile_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profile_save;

  /// No description provided for @profile_editAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profile_editAvatar;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_languageEnglish;

  /// No description provided for @settings_languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get settings_languageVietnamese;

  /// No description provided for @settings_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_darkMode;

  /// No description provided for @settings_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settings_contact;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_terms;

  /// No description provided for @contact_support_description.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with our support team'**
  String get contact_support_description;

  /// No description provided for @ai_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your SGTour virtual guide. Where would you like to go today?'**
  String get ai_greeting;

  /// No description provided for @ai_error.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I\'m having connection issues.'**
  String get ai_error;

  /// No description provided for @ai_mode_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get ai_mode_chat;

  /// No description provided for @ai_mode_video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get ai_mode_video;

  /// No description provided for @ai_listening.
  ///
  /// In en, this message translates to:
  /// **'I\'m listening...'**
  String get ai_listening;

  /// No description provided for @ai_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Ask SGTour about a place...'**
  String get ai_input_hint;

  /// Search result section header with query string.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String search_result_for(String query);

  /// No description provided for @biometric_login_face.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get biometric_login_face;

  /// No description provided for @biometric_login_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get biometric_login_fingerprint;

  /// No description provided for @biometric_login_with_face.
  ///
  /// In en, this message translates to:
  /// **'Login with Face ID'**
  String get biometric_login_with_face;

  /// No description provided for @biometric_login_with_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Login with Fingerprint'**
  String get biometric_login_with_fingerprint;

  /// No description provided for @biometric_enable_title.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get biometric_enable_title;

  /// No description provided for @biometric_enable_desc.
  ///
  /// In en, this message translates to:
  /// **'You will be asked to authenticate. Your biometric data will be securely stored.'**
  String get biometric_enable_desc;

  /// No description provided for @biometric_enabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login enabled'**
  String get biometric_enabled;

  /// No description provided for @biometric_disabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login disabled'**
  String get biometric_disabled;

  /// No description provided for @biometric_not_available.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available'**
  String get biometric_not_available;

  /// No description provided for @biometric_setup_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to setup biometric authentication'**
  String get biometric_setup_failed;

  /// No description provided for @biometric_quick_login.
  ///
  /// In en, this message translates to:
  /// **'Enable quick login'**
  String get biometric_quick_login;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'fr',
    'hi',
    'ja',
    'ko',
    'ru',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
