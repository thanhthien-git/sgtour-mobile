import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/widgets/map/user_location_marker.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../models/place/place_models.dart';
import '../../enums/enums.dart';
import '../../widgets/common/draggable_floating_bubble.dart';
import '../../widgets/map/map_widgets.dart';
import '../../widgets/place/place_widgets.dart';

/// Map screen with OpenStreetMap, user location, nearby places and AI assistant
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController? _mapController;
  bool _mapReady = false;

  LatLng? _userLocation;
  bool _isLoadingLocation = true;
  bool _showAiAssistant = false;
  AiAssistantMode _aiMode = AiAssistantMode.chat;
  final List<AiChatMessage> _chatMessages = [];
  String _locationName = 'Đang tải...';

  final List<NearbyLocation> _nearbyLocations = const [
    NearbyLocation(
      id: '1',
      name: 'Snow Town Sài Gòn',
      address: 'TP Thủ Đức, TP.HCM',
      imageUrl: null,
    ),
    NearbyLocation(
      id: '2',
      name: 'Landmark 81',
      address: 'Bình Thạnh, TP.HCM',
      imageUrl: null,
    ),
    NearbyLocation(
      id: '3',
      name: 'Chợ Bến Thành',
      address: 'Quận 1, TP.HCM',
      imageUrl: null,
    ),
  ];

  static const _defaultLocation = LatLng(10.8231, 106.6297);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      // First check if location service (GPS) is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Prompt user to enable GPS
        if (mounted) {
          setState(() {
            _userLocation = _defaultLocation;
            _isLoadingLocation = false;
            _locationName = 'Bật GPS để xem vị trí';
          });
          // Try to open location settings
          await Geolocator.openLocationSettings();
        }
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _userLocation = _defaultLocation;
              _isLoadingLocation = false;
              _locationName = 'Cần quyền vị trí';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _userLocation = _defaultLocation;
            _isLoadingLocation = false;
            _locationName = 'Vui lòng cấp quyền vị trí';
          });
        }
        return;
      }

      // Get current position with high accuracy
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

        if (_mapReady && _mapController != null) {
          _mapController!.move(_userLocation!, 15);
        }
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        setState(() {
          _userLocation = _defaultLocation;
          _isLoadingLocation = false;
          _locationName = 'Không lấy được vị trí';
        });
      }
    }
  }

  void _centerOnUser() async {
    // If we don't have real location yet, try to get it
    if (_userLocation == _defaultLocation || _userLocation == null) {
      setState(() {
        _isLoadingLocation = true;
        _locationName = 'Đang tìm vị trí...';
      });
      await _initLocation();
      return;
    }

    if (_mapReady && _mapController != null) {
      _mapController!.move(_userLocation!, 15);
    }
  }

  void _toggleAiAssistant() {
    setState(() {
      _showAiAssistant = !_showAiAssistant;
    });
  }

  void _onAiModeChanged(AiAssistantMode mode) {
    setState(() {
      _aiMode = mode;
    });
  }

  void _onSendMessage(String message) {
    setState(() {
      _chatMessages.add(
        AiChatMessage(
          content: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _chatMessages.add(
            AiChatMessage(
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis bibendum tincidunt leo, non suscipit turpis condimentum eget. Cras est ligula, ullamcorper ut fringilla eu, scelerisque eget lectus.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  void _onLocationTap(NearbyLocation location) {
    // Mock Place data - replace with API call
    final mockPlace = _createMockPlace(
      location.id,
      location.name,
      location.address,
    );
    PlaceDetailSheet.show(context, mockPlace);
  }

  /// Creates mock Place for demo - will be replaced with API call
  Place _createMockPlace(String id, String name, String address) {
    return Place(
      id: id,
      location: _userLocation ?? _defaultLocation,
      defaultLanguage: PlaceLanguage.vi,
      categoryCode: 'giai_tri',
      metadata: PlaceMetadata(title: name, address: address),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      images: [
        PlaceImage(
          id: '1',
          placeId: id,
          url:
              'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800',
          isPrimary: true,
          createdAt: DateTime.now(),
        ),
        PlaceImage(
          id: '2',
          placeId: id,
          url:
              'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
          isPrimary: false,
          createdAt: DateTime.now(),
        ),
        PlaceImage(
          id: '3',
          placeId: id,
          url:
              'https://images.unsplash.com/photo-1555921015-5532091f6026?w=800',
          isPrimary: false,
          createdAt: DateTime.now(),
        ),
      ],
      translations: [
        PlaceTranslation(
          id: '1',
          placeId: id,
          language: PlaceLanguage.vi,
          content: [
            const PlaceContent(
              key: 'title',
              type: PlaceContentType.defaultType,
              value: 'Snow Town Sài Gòn',
            ),
            PlaceContent(
              key: 'address',
              type: PlaceContentType.defaultType,
              value: address,
            ),
            const PlaceContent(
              key: 'description',
              type: PlaceContentType.paragraph,
              value:
                  'Snow Town Sài Gòn là điểm đến nổi tiếng tại TP.HCM, mang đến trải nghiệm tuyết độc đáo giữa lòng thành phố.',
            ),
            const PlaceContent(
              key: 'opening_hours',
              type: PlaceContentType.defaultType,
              value: '08:30 - 21:00',
            ),
            const PlaceContent(
              key: 'ticket_price',
              type: PlaceContentType.defaultType,
              value: '30.000 - 200.000 VND',
            ),
            const PlaceContent(
              key: 'highlights',
              type: PlaceContentType.paragraph,
              value:
                  'Kiến trúc đặc sắc, lịch sử phong phú, nhiều hoạt động vui chơi và mua sắm.',
            ),
            const PlaceContent(
              key: 'tips',
              type: PlaceContentType.paragraph,
              value: 'Nên đến vào buổi sáng hoặc chiều muộn để tránh nắng gắt.',
            ),
            const PlaceContent(
              key: 'contact',
              type: PlaceContentType.defaultType,
              value: '(+84) 28 0000 0000',
            ),
            const PlaceContent(
              key: 'website',
              type: PlaceContentType.defaultType,
              value: 'https://example.com',
            ),
            const PlaceContent(
              key: 'best_time',
              type: PlaceContentType.defaultType,
              value: 'Cuối tuần, 17:00-20:00',
            ),
            const PlaceContent(
              key: 'accessibility',
              type: PlaceContentType.defaultType,
              value: 'Có ram cho xe lăn, bảng chỉ dẫn rõ ràng',
            ),
            const PlaceContent(
              key: 'nearby',
              type: PlaceContentType.paragraph,
              value: 'Gần phố đi bộ, trung tâm mua sắm, nhà thờ, bảo tàng',
            ),
          ],
        ),
        PlaceTranslation(
          id: '2',
          placeId: id,
          language: PlaceLanguage.en,
          content: [
            const PlaceContent(
              key: 'title',
              type: PlaceContentType.defaultType,
              value: 'Snow Town Saigon',
            ),
            PlaceContent(
              key: 'address',
              type: PlaceContentType.defaultType,
              value: address,
            ),
            const PlaceContent(
              key: 'description',
              type: PlaceContentType.paragraph,
              value:
                  'Snow Town Saigon is a famous attraction in Ho Chi Minh City, offering a unique snow experience.',
            ),
            const PlaceContent(
              key: 'opening_hours',
              type: PlaceContentType.defaultType,
              value: '08:30 - 21:00',
            ),
            const PlaceContent(
              key: 'ticket_price',
              type: PlaceContentType.defaultType,
              value: 'VND 30,000 - 200,000',
            ),
            const PlaceContent(
              key: 'highlights',
              type: PlaceContentType.paragraph,
              value:
                  'Iconic architecture, rich history, various entertainment and shopping.',
            ),
            const PlaceContent(
              key: 'tips',
              type: PlaceContentType.paragraph,
              value: 'Visit in the morning or late afternoon to avoid heat.',
            ),
            const PlaceContent(
              key: 'contact',
              type: PlaceContentType.defaultType,
              value: '(+84) 28 0000 0000',
            ),
            const PlaceContent(
              key: 'website',
              type: PlaceContentType.defaultType,
              value: 'https://example.com',
            ),
            const PlaceContent(
              key: 'best_time',
              type: PlaceContentType.defaultType,
              value: 'Weekend, 5pm-8pm',
            ),
            const PlaceContent(
              key: 'accessibility',
              type: PlaceContentType.defaultType,
              value: 'Wheelchair ramps, clear signage',
            ),
            const PlaceContent(
              key: 'nearby',
              type: PlaceContentType.paragraph,
              value: 'Near walking street, malls, cathedral, museums',
            ),
          ],
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_userLocation != null) {
      markers.add(UserLocationMarker.build(_userLocation!));
    }

    if (_userLocation != null) {
      for (int i = 0; i < _nearbyLocations.length; i++) {
        final location = _nearbyLocations[i];
        final offsetLat = (i - 1) * 0.008;
        final offsetLng = (i % 2 == 0 ? 1 : -1) * 0.012;

        markers.add(
          OsmMapView.createLocationMarker(
            position: LatLng(
              _userLocation!.latitude + offsetLat,
              _userLocation!.longitude + offsetLng,
            ),
            label: location.name,
            onTap: () => _onLocationTap(location),
          ),
        );
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildSearchBar(topPadding),
          _buildCenterButton(),

          if (_showAiAssistant)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AiAssistantSheet(
                messages: _chatMessages,
                mode: _aiMode,
                onModeChanged: _onAiModeChanged,
                onSendMessage: _onSendMessage,
                onClose: _toggleAiAssistant,
                videoAvatarUrl:
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
              ),
            ),

          // Draggable AI Bubble
          if (!_showAiAssistant)
            DraggableFloatingBubble(
              onTap: _toggleAiAssistant,
              initialTop: 80,
              initialRight: 16,
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_isLoadingLocation || _userLocation == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Create controller if not exists
    _mapController ??= MapController();

    return OsmMapView(
      center: _userLocation!,
      zoom: 15,
      mapController: _mapController,
      markers: _buildMarkers(),
      onMapReady: () {
        if (!_mapReady) {
          setState(() => _mapReady = true);
        }
      },
    );
  }

  Widget _buildSearchBar(double topPadding) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: topPadding + 16,
      left: 16,
      right: 16,
      child: Container(
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
                _locationName,
                style: AppTextStyles.body1.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.tune,
                size: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.bottom + 80,
      right: 16,
      child: GestureDetector(
        onTap: _centerOnUser,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.my_location, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
