/// Place image
class PlaceImage {
  final String id;
  final String placeId;
  final String url;
  final bool isPrimary;
  final DateTime createdAt;

  const PlaceImage({
    required this.id,
    required this.placeId,
    required this.url,
    required this.isPrimary,
    required this.createdAt,
  });

  factory PlaceImage.fromJson(Map<String, dynamic> json) {
    return PlaceImage(
      id: json['id'] as String,
      placeId: json['placeId'] as String,
      url: json['url'] as String,
      isPrimary: json['isPrimary'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
