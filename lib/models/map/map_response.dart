import 'map_marker.dart';

class MapResponse {
  final int ttl;
  final List<MapMarker> places;

  const MapResponse({required this.ttl, required this.places});

  factory MapResponse.fromJson(Map<String, dynamic> json) {
    return MapResponse(
      ttl: json['ttl'],
      places: (json['places'] as List)
          .map((e) => MapMarker.fromJson(e))
          .toList(),
    );
  }
}
