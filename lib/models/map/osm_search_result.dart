import 'package:latlong2/latlong.dart';

class OsmSearchResult {
  final String displayName;
  final LatLng point;

  OsmSearchResult({required this.displayName, required this.point});

  factory OsmSearchResult.fromJson(Map<String, dynamic> json) {
    return OsmSearchResult(
      displayName: json['display_name'] ?? '',
      point: LatLng(double.parse(json['lat']), double.parse(json['lon'])),
    );
  }
}
