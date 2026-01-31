import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sgtourcus/services/file/config_service.dart';
import 'dart:io';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:sgtourcus/services/map/map_style_service.dart';
import 'location_marker.dart';
import 'cluster_marker.dart';
import 'user_location_marker.dart';
import 'dart:math' as math;

class VietMapView extends StatefulWidget {
  final latlong.LatLng center;
  final double zoom;
  final MapController? mapController;
  final List<PlaceMarkerData> placeMarkers;
  final latlong.LatLng? userLocation;
  final void Function(MapCamera, bool)? onPositionChanged;
  final VoidCallback? onMapReady;
  final void Function(String placeId)? onPlaceMarkerTap;

  const VietMapView({
    super.key,
    required this.center,
    this.zoom = 12.0,
    this.mapController,
    required this.placeMarkers,
    this.userLocation,
    this.onPositionChanged,
    this.onMapReady,
    this.onPlaceMarkerTap,
  });

  @override
  State<VietMapView> createState() => _VietMapViewState();
}

class _VietMapViewState extends State<VietMapView>
    with TickerProviderStateMixin {
  VietmapController? _vietmapController;
  String? _styleString;
  bool _isLoadingStyle = true;
  List<Marker>? _cachedMarkers;
  List<PlaceMarkerData>? _lastMarkerData;
  double? _lastZoom;
  final Map<String, AnimationController> _markerAnimations = {};
  final Map<String, AnimationController> _clusterAnimations = {};

  static const double _clusterRadius = 80.0;
  static const int _minZoomForNoClustering = 16;

  @override
  void initState() {
    super.initState();
    _loadStyle();
  }

  @override
  void dispose() {
    for (final controller in _markerAnimations.values) {
      controller.dispose();
    }
    for (final controller in _clusterAnimations.values) {
      controller.dispose();
    }
    _markerAnimations.clear();
    _clusterAnimations.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(VietMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(oldWidget.placeMarkers, widget.placeMarkers)) {
      _cachedMarkers = null;
      _lastMarkerData = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadStyle() async {
    try {
      final style = await MapStyleService.instance.getStyleString();
      if (mounted) {
        setState(() {
          _styleString = style;
          _isLoadingStyle = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading map style: $e');
      if (mounted) {
        setState(() => _isLoadingStyle = false);
      }
    }
  }

  void _onMapCreated(VietmapController controller) {
    _vietmapController = controller;
    widget.mapController?._setController(controller);
    widget.onMapReady?.call();
  }

  void _onCameraIdle() {
    if (_vietmapController != null) {
      final position = _vietmapController!.cameraPosition;
      if (position != null) {
        final camera = MapCamera(
          center: latlong.LatLng(
            position.target.latitude,
            position.target.longitude,
          ),
          zoom: position.zoom,
        );

        if (_lastZoom != null &&
            ((_lastZoom! < _minZoomForNoClustering &&
                    position.zoom >= _minZoomForNoClustering) ||
                (_lastZoom! >= _minZoomForNoClustering &&
                    position.zoom < _minZoomForNoClustering) ||
                (position.zoom - _lastZoom!).abs() >= 1)) {
          _cachedMarkers = null;
          if (mounted) setState(() {});
        }
        _lastZoom = position.zoom;

        widget.onPositionChanged?.call(camera, false);
      }
    }
  }

  List<Marker> _buildMarkers() {
    final currentZoom = _vietmapController?.cameraPosition?.zoom ?? widget.zoom;

    if (_cachedMarkers != null &&
        _lastMarkerData != null &&
        _lastZoom != null &&
        (currentZoom - _lastZoom!).abs() < 1 &&
        _listEquals(_lastMarkerData!, widget.placeMarkers)) {
      return _cachedMarkers!;
    }

    _lastMarkerData = List.from(widget.placeMarkers);
    _lastZoom = currentZoom;

    if (currentZoom >= _minZoomForNoClustering) {
      _cachedMarkers = _buildIndividualMarkers();
    } else {
      _cachedMarkers = _buildClusteredMarkers(currentZoom);
    }

    return _cachedMarkers!;
  }

  List<Marker> _buildIndividualMarkers() {
    final currentMarkerKeys = <String>{};
    final markers = widget.placeMarkers.map((data) {
      final key = 'marker_${data.placeId}';
      currentMarkerKeys.add(key);

      if (!_markerAnimations.containsKey(key)) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );
        _markerAnimations[key] = controller;
        controller.forward();
      }

      final animation = CurvedAnimation(
        parent: _markerAnimations[key]!,
        curve: Curves.easeOutBack,
      );

      return Marker(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: animation.value,
                child: Opacity(opacity: animation.value, child: child),
              );
            },
            child: GestureDetector(
              onTap: () => widget.onPlaceMarkerTap?.call(data.placeId),
              child: LocationMarker(
                key: ValueKey(key),
                label: data.label,
                imageUrl: data.imageUrl,
                isSelected: false,
              ),
            ),
          ),
        ),
        latLng: LatLng(data.lat, data.lng),
      );
    }).toList();

    // Clean up animations for markers that no longer exist
    _cleanupAnimations(_markerAnimations, currentMarkerKeys);

    return markers;
  }

  List<Marker> _buildClusteredMarkers(double zoom) {
    if (widget.placeMarkers.isEmpty) return [];

    final clusters = _clusterMarkers(widget.placeMarkers, zoom);
    final markers = <Marker>[];
    final currentClusterKeys = <String>{};
    final currentMarkerKeys = <String>{};

    for (final cluster in clusters) {
      if (cluster.places.length == 1) {
        // Single marker with animation
        final data = cluster.places.first;
        final key = 'marker_${data.placeId}';
        currentMarkerKeys.add(key);

        // Create or get animation controller
        if (!_markerAnimations.containsKey(key)) {
          final controller = AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          );
          _markerAnimations[key] = controller;
          controller.forward();
        }

        final animation = CurvedAnimation(
          parent: _markerAnimations[key]!,
          curve: Curves.easeOutBack,
        );

        markers.add(
          Marker(
            width: 150,
            height: 150,
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: animation.value,
                    child: Opacity(opacity: animation.value, child: child),
                  );
                },
                child: GestureDetector(
                  onTap: () => widget.onPlaceMarkerTap?.call(data.placeId),
                  child: LocationMarker(
                    key: ValueKey(key),
                    label: data.label,
                    imageUrl: data.imageUrl,
                    isSelected: false,
                  ),
                ),
              ),
            ),
            latLng: LatLng(data.lat, data.lng),
          ),
        );
      } else {
        // Cluster marker with animation
        final key =
            'cluster_${cluster.centerLat.toStringAsFixed(4)}_${cluster.centerLng.toStringAsFixed(4)}';
        currentClusterKeys.add(key);

        // Create or get animation controller
        if (!_clusterAnimations.containsKey(key)) {
          final controller = AnimationController(
            duration: const Duration(milliseconds: 350),
            vsync: this,
          );
          _clusterAnimations[key] = controller;
          controller.forward();
        }

        final animation = CurvedAnimation(
          parent: _clusterAnimations[key]!,
          curve: Curves.elasticOut,
        );

        markers.add(
          Marker(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: animation.value,
                    child: Opacity(
                      opacity: animation.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: ClusterMarker(
                  key: ValueKey(key),
                  count: cluster.places.length,
                  onTap: () {
                    _vietmapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(cluster.centerLat, cluster.centerLng),
                        math.min(zoom + 3, 18),
                      ),
                    );
                  },
                ),
              ),
            ),
            latLng: LatLng(cluster.centerLat, cluster.centerLng),
          ),
        );
      }
    }

    // Clean up animations for clusters and markers that no longer exist
    _cleanupAnimations(_clusterAnimations, currentClusterKeys);
    _cleanupAnimations(_markerAnimations, currentMarkerKeys);

    return markers;
  }

  List<_MarkerCluster> _clusterMarkers(
    List<PlaceMarkerData> places,
    double zoom,
  ) {
    final gridSize = _getGridSize(zoom);
    final Map<String, _MarkerCluster> clusterMap = {};

    for (final place in places) {
      final gridKey = _getGridKey(place.lat, place.lng, gridSize);

      if (clusterMap.containsKey(gridKey)) {
        clusterMap[gridKey]!.places.add(place);
      } else {
        clusterMap[gridKey] = _MarkerCluster(
          centerLat: place.lat,
          centerLng: place.lng,
          places: [place],
        );
      }
    }

    for (final cluster in clusterMap.values) {
      if (cluster.places.length > 1) {
        double sumLat = 0;
        double sumLng = 0;
        for (final place in cluster.places) {
          sumLat += place.lat;
          sumLng += place.lng;
        }
        cluster.centerLat = sumLat / cluster.places.length;
        cluster.centerLng = sumLng / cluster.places.length;
      }
    }

    return clusterMap.values.toList();
  }

  double _getGridSize(double zoom) {
    // More aggressive clustering when zoomed out
    if (zoom >= 16) return 0.001; // ~100m
    if (zoom >= 15) return 0.002; // ~200m
    if (zoom >= 14) return 0.004; // ~400m
    if (zoom >= 13) return 0.008; // ~800m
    if (zoom >= 12) return 0.015; // ~1.5km
    if (zoom >= 11) return 0.025; // ~2.5km
    if (zoom >= 10) return 0.04; // ~4km
    if (zoom >= 9) return 0.06; // ~6km
    if (zoom >= 8) return 0.1; // ~10km
    return 0.2; // ~20km for very zoomed out
  }

  String _getGridKey(double lat, double lng, double gridSize) {
    final gridLat = (lat / gridSize).floor();
    final gridLng = (lng / gridSize).floor();
    return '${gridLat}_$gridLng';
  }

  void _cleanupAnimations(
    Map<String, AnimationController> animations,
    Set<String> currentKeys,
  ) {
    final keysToRemove = animations.keys
        .where((key) => !currentKeys.contains(key))
        .toList();
    for (final key in keysToRemove) {
      animations[key]?.dispose();
      animations.remove(key);
    }
  }

  bool _listEquals(List<PlaceMarkerData> a, List<PlaceMarkerData> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingStyle || _styleString == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final styleUrl = '${ConfigService.instance.apiBaseUrl}/tiles/style';

    return Stack(
      children: [
        VietmapGL(
          styleString: Platform.isIOS ? styleUrl : _styleString!,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.center.latitude, widget.center.longitude),
            zoom: widget.zoom,
          ),
          minMaxZoomPreference: const MinMaxZoomPreference(5, 22),
          trackCameraPosition: true,
          myLocationEnabled: true,
          myLocationTrackingMode: MyLocationTrackingMode.trackingCompass,
          onMapCreated: _onMapCreated,
          onCameraIdle: _onCameraIdle,
          logoEnabled: false,
        ),
        if (_vietmapController != null)
          MarkerLayer(
            ignorePointer: false,
            mapController: _vietmapController!,
            markers: _buildMarkers(),
          ),
        if (_vietmapController != null && widget.userLocation != null)
          MarkerLayer(
            ignorePointer: true,
            mapController: _vietmapController!,
            markers: [
              Marker(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: const UserLocationMarker(),
                latLng: LatLng(
                  widget.userLocation!.latitude,
                  widget.userLocation!.longitude,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class PlaceMarkerData {
  final String placeId;
  final double lat;
  final double lng;
  final String label;
  final String? imageUrl;

  const PlaceMarkerData({
    required this.placeId,
    required this.lat,
    required this.lng,
    required this.label,
    this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceMarkerData &&
          runtimeType == other.runtimeType &&
          placeId == other.placeId &&
          lat == other.lat &&
          lng == other.lng &&
          label == other.label &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      placeId.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      label.hashCode ^
      (imageUrl?.hashCode ?? 0);
}

class _MarkerCluster {
  double centerLat;
  double centerLng;
  final List<PlaceMarkerData> places;

  _MarkerCluster({
    required this.centerLat,
    required this.centerLng,
    required this.places,
  });
}

class MapCamera {
  final latlong.LatLng center;
  final double zoom;

  const MapCamera({required this.center, required this.zoom});
}

class MapController {
  VietmapController? _controller;

  void _setController(VietmapController controller) {
    _controller = controller;
  }

  void move(latlong.LatLng location, double zoom) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        zoom,
      ),
    );
  }

  void dispose() {}

  MapCamera get camera {
    final position = _controller?.cameraPosition;
    if (position != null) {
      return MapCamera(
        center: latlong.LatLng(
          position.target.latitude,
          position.target.longitude,
        ),
        zoom: position.zoom,
      );
    }
    return const MapCamera(center: latlong.LatLng(0, 0), zoom: 0);
  }
}
