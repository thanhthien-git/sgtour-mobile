import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/models/location_model.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';
import 'package:sgtour_mobile/repository/place_repository.dart';
import 'package:sgtour_mobile/screens/home/map/nearby_places_carousel.dart';
import 'package:sgtour_mobile/screens/home/map/tile_math.dart';
import 'package:sgtour_mobile/screens/qr_scanner_screen.dart';
import 'package:sgtour_mobile/services/map/cache/map_cache_service.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';
import 'package:sgtour_mobile/widgets/ai_human_avatar/avatar_controller.dart';
import 'package:sgtour_mobile/widgets/map/places_search_bar.dart';
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
  List<LocationModel> _carouselPlaces = [];

  bool _isAiSheetVisible = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    MapCacheService.instance.init();
    _initLocationInBackground();
  }

  void _initLocationInBackground() {
    _initLocation().catchError((e) {
      debugPrint("Background location initialization error: $e");
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
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
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
            ),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint("Location timeout - using default location");
              throw TimeoutException("Location request timeout");
            },
          );

      _updateLocationState(
        location: LatLng(position.latitude, position.longitude),
        isLoading: false,
        name: 'Vị trí hiện tại',
        shouldMoveMap: true,
      );
    } catch (e) {
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
    } else {
      AvatarController().cancelCloseSession();
      AvatarController().startSession();
    }

    setState(() => _isAiSheetVisible = isVisible);
  }

  void _onSearchPlaceSelected(LatLng location, String placeName) {
    if (_isMapReady) {
      _mapController.move(location, 16);
    }
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
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

          Positioned(
            top: topPadding + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: PlacesSearchBar(
                    hintText: context.l10n.map_search_hint,
                    onPlaceSelected: _onSearchPlaceSelected,
                  ),
                ),
                const SizedBox(width: 12),
                _buildCircleBtn(Icons.qr_code_scanner, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                  );
                }),
              ],
            ),
          ),
          if (_userLocation != null && keyboardHeight == 0)
            NearbyPlacesCarousel(
              userLocation: _userLocation,
              onPlaceTap: (place) {
                _mapController.move(
                  LatLng(place.location!.latitude!, place.location!.longitude!),
                  16,
                );
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
                    bottom: paddingBottom + navBarHeight * 2,
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
                    initialTop: 120,
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
                ? (keyboardHeight > 0 ? keyboardHeight : 0)
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

  Widget _buildCircleBtn(
    IconData icon,
    VoidCallback onTap, {
    Color bgColor = AppColors.primary,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}
