/// Model for news category (danh mục tin tức) from API
class NewsCategoryModel {
  final String id;
  final String name;
  final String? slug;

  const NewsCategoryModel({
    required this.id,
    required this.name,
    this.slug,
  });

  factory NewsCategoryModel.fromJson(Map<String, dynamic> json) {
    return NewsCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}
