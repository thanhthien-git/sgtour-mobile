import 'package:flutter/material.dart';

/// Model for category data
class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final IconData? icon;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'imageUrl': imageUrl};
  }

  /// Copy with method for immutability
  CategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    IconData? icon,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
    );
  }
}
