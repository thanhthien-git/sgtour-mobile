import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';
import 'package:sgtour_mobile/repository/place_repository.dart';
import 'package:sgtour_mobile/screens/home/map/tile_math.dart';
import 'package:sgtour_mobile/services/map_cache_service.dart';
import 'package:sgtour_mobile/widgets/map/user_location_marker.dart';

// Imports
import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../widgets/common/draggable_floating_bubble.dart';
import '../../../widgets/map/map_widgets.dart';
import '../../../widgets/place/place_widgets.dart';
import '../../../models/place/place_models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final MapRepository _mapRepo = MapRepository();

  List<MapPlace> _mapPlaces = [];
  LatLng? _userLocation;
  bool _isLoadingLocation = true;
  Set<String> _lastTileKeys = {};
  String _locationName = 'Đang tải...';
  bool _isMapReady = false;

  // AI Assistant State
  bool _showAiAssistant = false;

  Timer? _debounceTimer;
  static const _defaultLocation = LatLng(10.8231, 106.6297);

  @override
  void initState() {
    super.initState();
    MapCacheService.instance.init().then((_) {
      _initLocation();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        setState(() {
          _userLocation = _defaultLocation;
          _isLoadingLocation = false;
          _locationName = 'GPS chưa bật';
        });
      return;
    }
    if (_isMapReady) {
      _mapController.move(_userLocation!, 15);
    }
    // Check Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          setState(() {
            _userLocation = _defaultLocation;
            _isLoadingLocation = false;
            _locationName = 'Thiếu quyền vị trí';
          });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        setState(() {
          _userLocation = _defaultLocation;
          _isLoadingLocation = false;
          _locationName = 'Quyền vị trí bị chặn';
        });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
          _locationName = 'Vị trí hiện tại';
        });
        _mapController.move(_userLocation!, 15);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      if (_isMapReady) {
        _mapController.move(_userLocation!, 15);
      }
    } else {
      _initLocation();
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;

      final zoom = camera.zoom.round();
      final visibleTiles = TileMath.getVisibleTiles(camera, zoom);

      final newTileKeys = visibleTiles
          .map((t) => '${t.z}_${t.x}_${t.y}')
          .toSet();

      if (_lastTileKeys.length == newTileKeys.length &&
          _lastTileKeys.containsAll(newTileKeys)) {
        return;
      }

      _lastTileKeys = newTileKeys;

      final places = await _mapRepo.fetchTiles(visibleTiles);

      if (mounted) {
        setState(() {
          _mapPlaces = places;
        });
      }
    });
  }

  Future<void> _onPlaceTap(MapPlace mapPlace) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final fullPlace = await _mapRepo.getPlaceDetail(mapPlace.id);

      if (!mounted) return;
      Navigator.pop(context);

      PlaceDetailSheet.show(context, fullPlace);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_userLocation != null) {
      markers.add(UserLocationMarker.build(_userLocation!));
    }

    for (final place in _mapPlaces) {
      markers.add(
        OsmMapView.createLocationMarker(
          position: LatLng(place.lat, place.lng),
          label: place.name,
          onTap: () => _onPlaceTap(place),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          if (_isLoadingLocation && _userLocation == null)
            const Center(child: CircularProgressIndicator())
          else
            OsmMapView(
              center: _userLocation ?? _defaultLocation,
              zoom: 15,
              mapController: _mapController,
              markers: _buildMarkers(),
              onPositionChanged: _onMapPositionChanged,
              onMapReady: () {
                _isMapReady = true;
                if (_userLocation != null) {
                  _mapController.move(_userLocation!, 15);
                }
                _onMapPositionChanged(_mapController.camera, false);
              },
            ),

          // Search Bar
          Positioned(
            top: topPadding + 16,
            left: 16,
            right: 16,
            child: _MapSearchBar(locationName: _locationName, isDark: isDark),
          ),

          // Center Button
          Positioned(
            top: MediaQuery.of(context).padding.bottom + 80,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'center_btn',
              mini: true,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              onPressed: _centerOnUser,
              child: Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // AI Assistant Trigger
          if (!_showAiAssistant)
            DraggableFloatingBubble(
              onTap: () => setState(() => _showAiAssistant = true),
              initialTop: 80,
              initialRight: 16,
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),

          // Code AI Sheet của bạn ở đây...
        ],
      ),
    );
  }
}

class _MapSearchBar extends StatelessWidget {
  final String locationName;
  final bool isDark;
  const _MapSearchBar({required this.locationName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              locationName,
              style: AppTextStyles.body1.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.tune, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ],
      ),
    );
  }
}
