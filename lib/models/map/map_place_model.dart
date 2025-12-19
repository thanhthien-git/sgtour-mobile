class MapPlace {
  final String id;
  final String name;
  final double lat;
  final double lng;

  const MapPlace({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory MapPlace.fromJson(Map<String, dynamic> json) {
    return MapPlace(
      id: (json['markerId'] ?? json['placeId'] ?? '').toString(),
      name: json['name'] ?? 'Unknown',
      lat: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      lng: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'markerId': id, 'name': name, 'latitude': lat, 'longitude': lng};
  }
}
