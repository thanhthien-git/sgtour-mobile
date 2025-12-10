import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

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

class UserProfileModel {
  final String? id;
  final String name;
  final String email;
  final String? avatarUrl;
  final Gender gender;
  final DateTime? birthDate;
  final String? phoneNumber;

  const UserProfileModel({
    this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.gender = Gender.other,
    this.birthDate,
    this.phoneNumber,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    Gender? gender,
    DateTime? birthDate,
    String? phoneNumber,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'gender': gender.key,
      'birthDate': birthDate?.toIso8601String(),
      'phoneNumber': phoneNumber,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      gender: Gender.fromString(json['gender'] as String?),
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  /// Empty profile for new users
  static const UserProfileModel empty = UserProfileModel(name: '', email: '');

  /// Mock profile for testing
  static UserProfileModel mock = UserProfileModel(
    id: '1',
    name: 'Trần Văn A',
    email: 'name@sgtour.com',
    avatarUrl: 'assets/images/avatar_placeholder.png',
    gender: Gender.female,
    birthDate: DateTime(2025, 5, 19),
    phoneNumber: '0000000000',
  );
}
