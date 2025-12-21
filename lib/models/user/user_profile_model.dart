import '../../enums/gender.dart';

class UserProfileModel {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final Gender? gender;
  final DateTime? birthDate;
  final String? phoneNumber;
  final String? authProvider;
  final String? password;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.gender = Gender.other,
    this.birthDate,
    this.phoneNumber,
    this.password,
    this.authProvider,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    Gender? gender,
    DateTime? birthDate,
    String? phoneNumber,
    String? password,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
    );
  }

  static UserProfileModel empty() {
    return UserProfileModel(
      id: '',
      name: null,
      email: null,
      avatarUrl: null,
      gender: Gender.other,
      birthDate: null,
      phoneNumber: null,
      authProvider: null,
      password: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'gender': gender?.key,
      'birthday': birthDate?.toIso8601String(),
      'phone': phoneNumber,
      'password': password,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      gender: Gender.fromString(json['gender'] as String?),
      birthDate: json['birthday'] != null
          ? DateTime.parse(json['birthday'] as String)
          : null,
      phoneNumber: json['phone'] as String?,
      authProvider: json['authProvider'] as String?,
    );
  }
}
