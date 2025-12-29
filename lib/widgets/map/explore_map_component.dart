import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';
import 'package:sgtour_mobile/repository/place_repository.dart';
import 'package:sgtour_mobile/screens/home/map/tile_math.dart';
import 'package:sgtour_mobile/services/map_cache_service.dart';
import 'package:sgtour_mobile/widgets/ai_human_avatar/avatar_controller.dart';
import 'package:sgtour_mobile/widgets/common/draggable_floating_bubble.dart';
import 'package:sgtour_mobile/widgets/map/map_widgets.dart';
import 'package:sgtour_mobile/widgets/map/user_location_marker.dart';
import 'package:sgtour_mobile/widgets/place/place_widgets.dart';

class ExploreMapComponent extends StatefulWidget {
  final MapController mapController;
  final Function(LatLng)? onUserLocationUpdated;

  const ExploreMapComponent({
    super.key,
    required this.mapController,
    this.onUserLocationUpdated,
  });

  @override
  State<ExploreMapComponent> createState() => _ExploreMapComponentState();
}

class _ExploreMapComponentState extends State<ExploreMapComponent>
    with TickerProviderStateMixin {
  static const LatLng _defaultLocation = LatLng(10.8231, 106.6297);
  static const _debounceTime = Duration(milliseconds: 500);

  final MapRepository _mapRepo = MapRepository();

  LatLng? _userLocation;
  List<MapPlace> _mapPlaces = [];
  Set<String> _lastTileKeys = {};
  bool _isLoadingLocation = true;

  Timer? _debounceTimer;
  bool _isTrackingUser = true;
  bool _isAiSheetVisible = false;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initServices() async {
    await MapCacheService.instance.init();
    await _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _updateLocation(LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint("Init Location Error: $e");
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      _updateLocation(LatLng(position.latitude, position.longitude));
    });
  }

  void _updateLocation(LatLng location) {
    if (!mounted) return;
    setState(() => _userLocation = location);

    widget.onUserLocationUpdated?.call(location);

    if (_isTrackingUser && _isMapReady) {
      widget.mapController.move(location, widget.mapController.camera.zoom);
    }
  }

  void recenterUser() {
    if (_userLocation != null) {
      setState(() => _isTrackingUser = true);
      widget.mapController.move(_userLocation!, 15);
    } else {
      _initLocation();
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      setState(() => _isTrackingUser = false);
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTime, () {
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

    try {
      final places = await _mapRepo.fetchTiles(visibleTiles);
      if (mounted) {
        setState(() {
          _lastTileKeys = newTileKeys;
          _mapPlaces = places;
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  void _toggleAiSheet(bool isVisible) {
    if (!isVisible) {
      FocusScope.of(context).unfocus();
    } else {
      AvatarController().cancelCloseSession();
      AvatarController().startSession();
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
            VietMapView(
              center: _userLocation ?? _defaultLocation,
              zoom: 15,
              mapController: widget.mapController,
              markers: _buildMarkers(),
              onPositionChanged: _onMapPositionChanged,
              onMapReady: () {
                _isMapReady = true;
                if (_userLocation != null) {
                  widget.mapController.move(_userLocation!, 15);
                }
                _onMapPositionChanged(widget.mapController.camera, false);
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
                      onPressed: recenterUser,
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

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_userLocation != null) {
      markers.add(UserLocationMarker.build(_userLocation!));
    }

    for (final place in _mapPlaces) {
      markers.add(
        VietMapView.createLocationMarker(
          id: place.id,
          imageUrl: place.displayImage,
          position: LatLng(place.lat, place.lng),
          label: place.name,
          onTap: () => _onPlaceTap(place),
        ),
      );
    }
    return markers;
  }
}
