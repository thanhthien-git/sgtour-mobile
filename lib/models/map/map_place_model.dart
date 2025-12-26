class MapPlace {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? displayImage;

  const MapPlace({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.displayImage,
  });

  factory MapPlace.fromJson(Map<String, dynamic> json) {
    return MapPlace(
      id: (json['markerId'] ?? json['placeId'] ?? '').toString(),
      name: json['name'] ?? 'Unknown',
      lat: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      lng: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      displayImage: json['displayImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'markerId': id,
      'name': name,
      'latitude': lat,
      'longitude': lng,
      'displayImage': displayImage,
    };
  }
}
