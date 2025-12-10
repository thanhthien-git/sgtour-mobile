import 'package:flutter/material.dart';

/// Model for language option data
class LanguageOptionModel {
  final Locale locale;
  final String title;
  final String subtitle;

  const LanguageOptionModel({
    required this.locale,
    required this.title,
    required this.subtitle,
  });
}
