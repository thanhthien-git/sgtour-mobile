class PlaceImage {
  final String id;
  final String url;
  final bool isPrimary;

  const PlaceImage({
    required this.id,
    required this.url,
    required this.isPrimary,
  });

  factory PlaceImage.fromJson(Map<String, dynamic> json) {
    return PlaceImage(
      id: json['id'] as String,
      url: json['url'] as String,
      isPrimary: json['isPrimary'] as bool,
    );
  }
}
