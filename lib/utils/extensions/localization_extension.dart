import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

/// Extension for easy access to AppLocalizations
/// Usage: context.l10n.someKey
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Extension for nullable context (useful in some cases)
extension LocalizationNullableExtension on BuildContext? {
  AppLocalizations? get l10n =>
      this != null ? AppLocalizations.of(this!) : null;
}
