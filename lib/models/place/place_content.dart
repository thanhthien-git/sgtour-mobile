import '../../enums/place_content_type.dart';

class PlaceContent {
  final String key;
  final PlaceContentType type;
  final bool? isHighlight;
  final String value;

  const PlaceContent({
    required this.key,
    required this.type,
    required this.value,
    this.isHighlight = false,
  });

  factory PlaceContent.fromJson(Map<String, dynamic> json) {
    return PlaceContent(
      key: json['key'] as String? ?? '',
      type: PlaceContentType.fromValue(json['type'] as String? ?? 'default'),
      isHighlight: json['isHighlight'] as bool? ?? false,
      value: json['value'] as String? ?? '',
    );
  }

  bool get isParagraph => type == PlaceContentType.paragraph;
}
