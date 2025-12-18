import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_colors.dart';
import 'location_marker.dart';

class OsmMapView extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final MapController? mapController;
  final List<Marker>? markers;
  final bool interactionEnabled;
  final void Function(MapCamera, bool)? onPositionChanged;
  final VoidCallback? onMapReady;

  const OsmMapView({
    super.key,
    required this.center,
    this.zoom = 13.0,
    this.mapController,
    this.markers,
    this.interactionEnabled = true,
    this.onPositionChanged,
    this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: InteractionOptions(
          flags: interactionEnabled
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
        onPositionChanged: onPositionChanged,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.sgtour.mobile',
          maxZoom: 19,
        ),
        if (markers != null && markers!.isNotEmpty)
          MarkerLayer(markers: markers!),
      ],
    );
  }

  /// Factory to create a user location marker
  static Marker createLocationMarker({
    required LatLng position,
    required String label,
    VoidCallback? onTap,
  }) {
    return Marker(
      point: position,
      width: 120,
      height: 40,
      child: GestureDetector(
        onTap: onTap,
        child: LocationMarker(label: label),
      ),
    );
  }
}
