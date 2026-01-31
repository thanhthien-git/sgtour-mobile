import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtourcus/models/location_model.dart';
import 'package:sgtourcus/models/map/map_place_model.dart';
import 'package:sgtourcus/repository/place_repository.dart';
import 'package:sgtourcus/screens/home/map/nearby_places_carousel.dart';
import 'package:sgtourcus/screens/home/map/tile_math.dart';
import 'package:sgtourcus/services/map/cache/map_cache_service.dart';
import 'package:sgtourcus/services/map/cache/tile_cache_manager.dart';
import 'package:sgtourcus/utils/extensions/localization_extension.dart';
import 'package:sgtourcus/widgets/ai_human_avatar/avatar_controller.dart';
import 'package:sgtourcus/widgets/map/places_search_bar.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/common/draggable_floating_bubble.dart';
import '../../../widgets/map/map_widgets.dart';
import '../../../widgets/place/place_widgets.dart';
import '../../../widgets/map/viet_map_view.dart' as vietmap;

class MapScreen extends StatefulWidget {
  final ValueChanged<bool>? onNavBarVisibilityChanged;

  const MapScreen({super.key, this.onNavBarVisibilityChanged});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  static const _defaultLocation = LatLng(10.8231, 106.6297);
  static const _debounceTime = Duration(milliseconds: 700);

  final vietmap.MapController _mapController = vietmap.MapController();
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
    _initCaches();
    _initLocationInBackground();
  }

  Future<void> _initCaches() async {
    await MapCacheService.instance.init();
    await TileCacheManager.instance.init();
  }

  void _initLocationInBackground() {
    _initLocation().catchError((e) {
      debugPrint("Background location initialization error: $e");
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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

  void _onMapPositionChanged(vietmap.MapCamera camera, bool hasGesture) {
    final currentCenter = camera.center;

    // At high zoom (>16), reduce distance threshold for better marker visibility
    final distanceThreshold = camera.zoom > 16 ? 50.0 : 100.0;

    if (_lastFetchLocation != null) {
      double distance = Geolocator.distanceBetween(
        _lastFetchLocation!.latitude,
        _lastFetchLocation!.longitude,
        currentCenter.latitude,
        currentCenter.longitude,
      );

      if (distance < distanceThreshold) return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTime, () {
      _lastFetchLocation = currentCenter;
      _fetchVisibleTiles(camera);
    });
  }

  Future<void> _fetchVisibleTiles(vietmap.MapCamera camera) async {
    if (!mounted) return;

    // Clamp zoom between 8 and 18 for tile fetching (max tile zoom is 18)
    final zoom = camera.zoom.clamp(8.0, 18.0).round();
    final visibleTiles = TileMath.getVisibleTilesFromLatLng(
      camera.center,
      zoom,
      buffer: 1,
    );
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

    // Ẩn/hiện nav bar khi AI sheet mở/đóng
    widget.onNavBarVisibilityChanged?.call(!isVisible);
  }

  void _onSearchPlaceSelected(LatLng location, String placeName) {
    if (_isMapReady) {
      _mapController.move(location, 16);
      _debounceTimer?.cancel();
      _lastFetchLocation = location;
      _fetchVisibleTiles(vietmap.MapCamera(center: location, zoom: 16));
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

  List<vietmap.PlaceMarkerData> _buildPlaceMarkers() {
    return _mapPlaces.map((place) {
      return vietmap.PlaceMarkerData(
        placeId: place.id,
        lat: place.lat,
        lng: place.lng,
        label: place.name,
        imageUrl: place.displayImage,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final paddingBottom = mediaQuery.padding.bottom;
    const double navBarHeight = 80.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (_isLoadingLocation && _userLocation == null)
            const Center(child: CircularProgressIndicator())
          else
            vietmap.VietMapView(
              center: _userLocation ?? _defaultLocation,
              zoom: 15,
              mapController: _mapController,
              placeMarkers: _buildPlaceMarkers(),
              userLocation: _userLocation,
              onPlaceMarkerTap: (placeId) {
                final place = _mapPlaces.firstWhere((p) => p.id == placeId);
                _onPlaceTap(place);
              },
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
            child: PlacesSearchBar(
              hintText: context.l10n.map_search_hint,
              onPlaceSelected: _onSearchPlaceSelected,
            ),
          ),
          if (_userLocation != null && keyboardHeight == 0)
            NearbyPlacesCarousel(
              userLocation: _userLocation,
              onPlaceTap: (place) {
                final location = LatLng(
                  place.location!.latitude!,
                  place.location!.longitude!,
                );
                _mapController.move(location, 16);
                // Force immediate tile fetch after navigation
                _debounceTimer?.cancel();
                _lastFetchLocation = location;
                _fetchVisibleTiles(
                  vietmap.MapCamera(center: location, zoom: 16),
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
                ? 0 // Nav bar đã ẩn nên bottom = 0
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
