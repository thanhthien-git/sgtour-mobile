import '../../enums/place_language.dart';
import 'place_content.dart';

class PlaceTranslation {
  final String id;
  final PlaceLanguage language;
  final List<PlaceContent> content;

  const PlaceTranslation({
    required this.id,
    required this.language,
    required this.content,
  });

  factory PlaceTranslation.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> _safeMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return {};
    }

    return PlaceTranslation(
      id: json['id'] as String? ?? '',
      language: PlaceLanguage.fromCode(json['languageCode'] as String? ?? 'en'),
      content:
          (json['content'] as List?)
              ?.map((e) => PlaceContent.fromJson(_safeMap(e)))
              .toList() ??
          [],
    );
  }

  String? getValue(String key) {
    final item = content.where((c) => c.key == key).firstOrNull;
    return item?.value;
  }

  PlaceContent? getContent(String key) {
    return content.where((c) => c.key == key).firstOrNull;
  }

  String get title => getValue('title') ?? '';
  String get address => getValue('address') ?? '';
}
