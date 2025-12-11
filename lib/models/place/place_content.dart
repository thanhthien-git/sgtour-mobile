import '../../enums/place_content_type.dart';

/// Translation content item
class PlaceContent {
  final String key;
  final PlaceContentType type;
  final String value;

  const PlaceContent({
    required this.key,
    required this.type,
    required this.value,
  });

  factory PlaceContent.fromJson(Map<String, dynamic> json) {
    return PlaceContent(
      key: json['key'] as String,
      type: PlaceContentType.fromValue(json['type'] as String),
      value: json['value'] as String,
    );
  }

  bool get isParagraph => type == PlaceContentType.paragraph;
}
