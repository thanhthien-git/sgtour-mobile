import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';
import 'package:sgtour_mobile/repository/place_repository.dart';
import 'package:sgtour_mobile/screens/home/map/tile_math.dart';
import 'package:sgtour_mobile/services/map_cache_service.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/common/draggable_floating_bubble.dart';
import '../../../widgets/map/map_widgets.dart';
import '../../../widgets/place/place_widgets.dart';
import '../../../widgets/map/user_location_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  static const _defaultLocation = LatLng(10.8231, 106.6297);
  static const _debounceTime = Duration(milliseconds: 700);

  late final MapController _mapController;
  final MapRepository _mapRepo = MapRepository();

  List<MapPlace> _mapPlaces = [];
  LatLng? _userLocation;
  bool _isLoadingLocation = true;
  Set<String> _lastTileKeys = {};
  String _locationName = 'Đang tải...';
  bool _isMapReady = false;
  Timer? _debounceTimer;
  LatLng? _lastFetchLocation;

  bool _isAiSheetVisible = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initServices();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    await MapCacheService.instance.init();
    await _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateLocationState(
        location: _defaultLocation,
        isLoading: false,
        name: 'GPS chưa bật',
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _updateLocationState(
          location: _defaultLocation,
          isLoading: false,
          name: 'Thiếu quyền vị trí',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updateLocationState(
        location: _defaultLocation,
        isLoading: false,
        name: 'Quyền vị trí bị chặn',
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _updateLocationState(
        location: LatLng(position.latitude, position.longitude),
        isLoading: false,
        name: 'Vị trí hiện tại',
        shouldMoveMap: true,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _updateLocationState({
    required LatLng location,
    required bool isLoading,
    required String name,
    bool shouldMoveMap = false,
  }) {
    if (!mounted) return;
    setState(() {
      _userLocation = location;
      _isLoadingLocation = isLoading;
      _locationName = name;
    });

    if (shouldMoveMap && _isMapReady) {
      _mapController.move(location, 15);
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
    final currentCenter = camera.center;

    if (_lastFetchLocation != null) {
      double distance = Geolocator.distanceBetween(
        _lastFetchLocation!.latitude,
        _lastFetchLocation!.longitude,
        currentCenter.latitude,
        currentCenter.longitude,
      );

      if (distance < 100) return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTime, () {
      _lastFetchLocation = currentCenter;
      _fetchVisibleTiles(camera);
    });
  }

  Future<void> _fetchVisibleTiles(MapCamera camera) async {
    if (!mounted) return;

    final zoom = camera.zoom.round();
    final visibleTiles = TileMath.getVisibleTiles(camera, zoom, buffer: 0);
    final newTileKeys = visibleTiles.map((t) => '${t.z}_${t.x}_${t.y}').toSet();

    if (_lastTileKeys.containsAll(newTileKeys) &&
        _lastTileKeys.length == newTileKeys.length) {
      return;
    }

    final places = await _mapRepo.fetchTiles(visibleTiles);

    if (mounted) {
      setState(() {
        _lastTileKeys = newTileKeys;
        _mapPlaces = places;
      });
    }
  }

  void _toggleAiSheet(bool isVisible) {
    if (!isVisible) {
      FocusScope.of(context).unfocus();
    }
    setState(() => _isAiSheetVisible = isVisible);
  }

  Future<void> _onPlaceTap(MapPlace mapPlace) async {
    if (_isAiSheetVisible) _toggleAiSheet(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
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
          id: place.id,
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
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final paddingBottom = mediaQuery.padding.bottom;
    const double navBarHeight = 80.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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

          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isAiSheetVisible ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: _isAiSheetVisible,
              child: Stack(
                children: [
                  Positioned(
                    bottom: paddingBottom + navBarHeight,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'center_btn',
                      mini: true,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      onPressed: _centerOnUser,
                      child: Icon(Icons.my_location, color: AppColors.primary),
                    ),
                  ),
                  DraggableFloatingBubble(
                    onTap: () => _toggleAiSheet(true),
                    initialTop: 80,
                    initialRight: 16,
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          if (_isAiSheetVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _toggleAiSheet(false),
                child: Container(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            left: 0,
            right: 0,

            bottom: _isAiSheetVisible
                ? (keyboardHeight > 0 ? keyboardHeight : (paddingBottom))
                : -mediaQuery.size.height,

            child: AiAssistantSheet(
              userLocation: _userLocation,
              onClose: () => _toggleAiSheet(false),
            ),
          ),
        ],
      ),
    );
  }
}
