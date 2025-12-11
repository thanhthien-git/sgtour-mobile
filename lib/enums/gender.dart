import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

/// Gender options for user profile
enum Gender {
  male,
  female,
  other;

  String get key {
    switch (this) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
      case Gender.other:
        return 'other';
    }
  }

  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case Gender.male:
        return l10n.profile_genderMale;
      case Gender.female:
        return l10n.profile_genderFemale;
      case Gender.other:
        return l10n.profile_genderOther;
    }
  }

  static List<DropdownMenuItem<Gender>> getDropdownItems(
    AppLocalizations l10n,
  ) {
    return Gender.values
        .map(
          (gender) => DropdownMenuItem(
            value: gender,
            child: Text(gender.getDisplayName(l10n)),
          ),
        )
        .toList();
  }

  static Gender fromString(String? value) {
    switch (value) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.other;
    }
  }
}
