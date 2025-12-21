import '../../enums/place_language.dart';
import 'place_content.dart';

class PlaceTranslation {
  final String id;
  final String placeId;
  final PlaceLanguage language;
  final List<PlaceContent> content;

  const PlaceTranslation({
    required this.id,
    required this.placeId,
    required this.language,
    required this.content,
  });

  factory PlaceTranslation.fromJson(Map<String, dynamic> json) {
    return PlaceTranslation(
      id: json['id'] as String,
      placeId: json['placeId'] as String,
      language: PlaceLanguage.fromCode(json['languageCode'] as String),
      content: (json['content'] as List)
          .map((e) => PlaceContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get content value by key
  String? getValue(String key) {
    final item = content.where((c) => c.key == key).firstOrNull;
    return item?.value;
  }

  /// Get content item by key
  PlaceContent? getContent(String key) {
    return content.where((c) => c.key == key).firstOrNull;
  }

  // Common getters for header display
  String get title => getValue('title') ?? '';
  String get address => getValue('address') ?? '';
}
