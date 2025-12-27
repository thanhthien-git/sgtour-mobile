import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_colors.dart';
import '../../services/config_service.dart';
import 'location_marker.dart';
import 'map_search_bar.dart';

class VietMapView extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final MapController? mapController;
  final List<Marker> markers;
  final void Function(MapCamera, bool)? onPositionChanged;
  final VoidCallback? onMapReady;

  const VietMapView({
    super.key,
    required this.center,
    this.zoom = 13.0,
    this.mapController,
    required this.markers,
    this.onPositionChanged,
    this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    final apiKey = ConfigService.instance.vietmapApiKey ?? '';

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            minZoom: 5,
            maxZoom: 20, // Vietmap raster hỗ trợ zoom khá sâu
            onPositionChanged: onPositionChanged,
            onMapReady: onMapReady,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://maps.vietmap.vn/tm/{z}/{x}/{y}.png?apikey={apikey}',
              additionalOptions: {'apikey': apiKey},

              userAgentPackageName: 'com.sgtour.mobile',
              keepBuffer: 10,
            ),

            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('Vietmap', prependCopyright: true),
              ],
            ),

            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 45,
                size: const Size(40, 40),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                markers: markers,
                zoomToBoundsOnClick: true,
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                animationsOptions: const AnimationsOptions(
                  zoom: Duration(milliseconds: 300),
                  fitBound: Duration(milliseconds: 300),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: MapSearchBar(
                onResultSelected: (result) {
                  // Lưu ý: search result trả về LatLng của latlong2
                  // nên dùng trực tiếp được
                  mapController?.move(result.point, 15.0);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Marker createLocationMarker({
    required LatLng position,
    required String label,
    required String id,
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return Marker(
      key: ValueKey('marker_place_$id'),
      point: position,
      width: 140, // Width đủ rộng cho cái label
      height: 60,
      alignment:
          Alignment.topCenter, // Căn chỉnh để mũi nhọn marker trúng vị trí
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: LocationMarker(label: label, imageUrl: imageUrl),
      ),
    );
  }
}
