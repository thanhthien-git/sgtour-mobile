import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';

@immutable
class MapMarker {
  final String markerId;
  final String? placeId;
  final String name;
  final double latitude;
  final double longitude;

  const MapMarker({
    required this.markerId,
    this.placeId,
    required this.name,
    required this.latitude,
    required this.longitude,
  }) : assert(
         latitude >= -90 && latitude <= 90,
         'latitude must be between -90 and 90',
       ),
       assert(
         longitude >= -180 && longitude <= 180,
         'longitude must be between -180 and 180',
       );

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      markerId: json['markerId'] as String,
      placeId: json['placeId'] as String?,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'markerId': markerId,
      'placeId': placeId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  @override
  String toString() {
    return 'MapMarker('
        'markerId: $markerId, '
        'placeId: $placeId, '
        'name: $name, '
        'lat: $latitude, '
        'lng: $longitude'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapMarker &&
        other.markerId == markerId &&
        other.placeId == placeId &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return markerId.hashCode ^
        placeId.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}
