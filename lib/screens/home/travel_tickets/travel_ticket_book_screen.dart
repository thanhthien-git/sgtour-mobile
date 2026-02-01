import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/location_model.dart';
import 'package:sgtourcus/models/map/get_nearest_place_dto.dart';
import 'package:sgtourcus/models/ticket/booking_payment_model.dart';
import 'package:sgtourcus/screens/home/travel_tickets/travel_ticket_payment_screen.dart';
import 'package:sgtourcus/services/map/cache/map_cache_service.dart';
import 'package:sgtourcus/services/map/cache/tile_cache_manager.dart';
import 'package:sgtourcus/services/map/map_service.dart';
import 'package:sgtourcus/widgets/map/viet_map_view.dart' as vietmap;

/// Màn hình "Mua vé": Tab Vé theo tour / Vé cá nhân, map bên dưới, Đặt vé → Thanh toán.
const _defaultCenterLat = 10.8231;
const _defaultCenterLng = 106.6297;
final _defaultCenter = LatLng(_defaultCenterLat, _defaultCenterLng);

class TravelTicketBookScreen extends StatefulWidget {
  const TravelTicketBookScreen({super.key});

  @override
  State<TravelTicketBookScreen> createState() => _TravelTicketBookScreenState();
}

class _TravelTicketBookScreenState extends State<TravelTicketBookScreen> with SingleTickerProviderStateMixin {
  static const List<String> _timeSlots = [
    '06:00 – 08:00',
    '08:00 – 10:00',
    '10:00 – 12:00',
    '12:00 – 14:00',
    '14:00 – 16:00',
    '16:00 – 18:00',
  ];

  late TabController _tabController;
  final vietmap.MapController _mapController = vietmap.MapController();

  List<LocationModel> _locations = [];
  bool _loadingLocations = true;

  String? _tourTimeSlot;
  LocationModel? _tourDeparture;
  final List<LocationModel> _tourStops = [];

  String? _personalTimeSlot;
  LocationModel? _personalDeparture;
  final List<LocationModel> _personalStops = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
      _onLocationSelected();
    });
    _tourTimeSlot = _timeSlots.first;
    _personalTimeSlot = _timeSlots.first;
    _initMapCaches();
    _loadLocations();
  }

  Future<void> _initMapCaches() async {
    try {
      await MapCacheService.instance.init();
      await TileCacheManager.instance.init();
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  LocationModel? get _selectedLocation {
    if (_tabController.index == 0) {
      if (_tourDeparture != null) return _tourDeparture;
      return _tourStops.isNotEmpty ? _tourStops.first : null;
    }
    if (_personalDeparture != null) return _personalDeparture;
    return _personalStops.isNotEmpty ? _personalStops.first : null;
  }

  LatLng get _mapCenter {
    final loc = _selectedLocation;
    if (loc?.location?.latitude != null && loc?.location?.longitude != null) {
      return LatLng(loc!.location!.latitude!, loc.location!.longitude!);
    }
    return _defaultCenter;
  }

  List<vietmap.PlaceMarkerData> get _mapMarkers {
    final loc = _selectedLocation;
    if (loc?.location?.latitude == null || loc?.location?.longitude == null) return [];
    return [
      vietmap.PlaceMarkerData(
        placeId: loc!.id,
        lat: loc.location!.latitude!,
        lng: loc.location!.longitude!,
        label: loc.metadata?.title ?? loc.id,
        imageUrl: loc.imageUrl,
      ),
    ];
  }

  void _onLocationSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = _selectedLocation;
      if (loc?.location?.latitude != null && loc?.location?.longitude != null) {
        _mapController.move(
          LatLng(loc!.location!.latitude!, loc.location!.longitude!),
          16,
        );
      }
    });
  }

  Future<void> _loadLocations() async {
    setState(() => _loadingLocations = true);
    try {
      final dto = GetNearestPlaceDto(
        latitude: _defaultCenterLat,
        longitude: _defaultCenterLng,
        page: 1,
        limit: 50,
      );
      final list = await MapService.getNearestLocations(dto);
      if (mounted) setState(() {
        _locations = list;
        _loadingLocations = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _locations = [];
        _loadingLocations = false;
      });
    }
  }

  static String _locationTitle(LocationModel loc) => loc.metadata?.title ?? loc.id;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
        title: const Text('Mua vé'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loadingLocations
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: surfaceColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Vé theo tour'),
                      Tab(text: 'Vé cá nhân'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: _buildTourForm(context, textSecondary, borderColor),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: _buildPersonalForm(context, textSecondary, borderColor),
                      ),
                    ],
                  ),
                ),
                _buildMapSection(surfaceColor),
              ],
            ),
    );
  }

  Widget _buildMapSection(Color surfaceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Bản đồ', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600)),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: vietmap.VietMapView(
              center: _mapCenter,
              zoom: _selectedLocation != null ? 16.0 : 14.0,
              mapController: _mapController,
              placeMarkers: _mapMarkers,
              onMapReady: () {
                if (_selectedLocation?.location != null) {
                  _mapController.move(
                    LatLng(
                      _selectedLocation!.location!.latitude!,
                      _selectedLocation!.location!.longitude!,
                    ),
                    16,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTourForm(BuildContext context, Color textSecondary, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tour_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Vé theo tour', style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        _TimeSlotRow(value: _tourTimeSlot ?? _timeSlots.first, items: _timeSlots, onChanged: (v) => setState(() => _tourTimeSlot = v)),
        const SizedBox(height: 10),
        _SearchableLocationField(
          label: 'Bến xuất phát',
          value: _tourDeparture,
          options: _locations,
          onTap: () => _showLocationPicker(context, 'Chọn bến xuất phát', _locations, (loc) {
            setState(() => _tourDeparture = loc);
            _onLocationSelected();
            Navigator.of(context).pop();
          }),
        ),
        const SizedBox(height: 10),
        _SearchableLocationField(
          label: 'Bến dừng',
          value: _tourStops.isEmpty ? null : _tourStops.last,
          options: _locations,
          onTap: () => _showLocationPicker(context, 'Thêm bến dừng', _locations, (loc) {
            if (_tourStops.any((s) => s.id == loc.id)) return;
            setState(() => _tourStops.add(loc));
            _onLocationSelected();
            Navigator.of(context).pop();
          }),
        ),
        if (_tourStops.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _tourStops.map((s) {
              return Chip(
                label: Text(_locationTitle(s), style: AppTextStyles.caption),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => setState(() => _tourStops.remove(s)),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _openPayment(BookingType.tour),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Đặt vé theo tour'),
          ),
        ),
      ],
    );
  }

  void _openPayment(BookingType type) {
    final departureName = type == BookingType.tour
        ? (_tourDeparture != null ? _locationTitle(_tourDeparture!) : '')
        : (_personalDeparture != null ? _locationTitle(_personalDeparture!) : '');
    final stopNames = type == BookingType.tour
        ? _tourStops.map(_locationTitle).toList()
        : _personalStops.map(_locationTitle).toList();
    final timeSlot = type == BookingType.tour ? (_tourTimeSlot ?? _timeSlots.first) : (_personalTimeSlot ?? _timeSlots.first);
    final amountVnd = 85000.0;
    final userName = 'Nguyễn Văn A';
    final userPhone = '0901234567';
    final booking = BookingPaymentModel(
      type: type,
      departureName: departureName,
      stopNames: stopNames,
      timeSlot: timeSlot,
      amountVnd: amountVnd,
      userName: userName,
      userPhone: userPhone,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TravelTicketPaymentScreen(booking: booking),
      ),
    );
  }

  Widget _buildPersonalForm(BuildContext context, Color textSecondary, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Vé theo cá nhân', style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        _TimeSlotRow(value: _personalTimeSlot ?? _timeSlots.first, items: _timeSlots, onChanged: (v) => setState(() => _personalTimeSlot = v)),
        const SizedBox(height: 10),
        _SearchableLocationField(
          label: 'Điểm xuất phát',
          value: _personalDeparture,
          options: _locations,
          onTap: () => _showLocationPicker(context, 'Chọn điểm xuất phát', _locations, (loc) {
            setState(() => _personalDeparture = loc);
            _onLocationSelected();
            Navigator.of(context).pop();
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Các điểm dừng', style: AppTextStyles.subtitle2),
            TextButton.icon(
              onPressed: _locations.isEmpty ? null : () => _showLocationPicker(context, 'Thêm điểm dừng', _locations.where((l) => !_personalStops.any((s) => s.id == l.id)).toList(), (loc) {
                setState(() => _personalStops.add(loc));
                _onLocationSelected();
                Navigator.of(context).pop();
              }),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Thêm điểm'),
            ),
          ],
        ),
        if (_personalStops.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt_outlined, color: textSecondary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chưa có điểm dừng. Nhấn "Thêm điểm" để chọn từ danh mục.',
                    style: AppTextStyles.body2.copyWith(color: textSecondary, fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: _personalStops.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${e.key + 1}', style: AppTextStyles.subtitle2.copyWith(color: AppColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_locationTitle(e.value), style: AppTextStyles.body2)),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: AppColors.error),
                      onPressed: () => setState(() => _personalStops.removeAt(e.key)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _openPayment(BookingType.personal),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Đặt vé theo cá nhân'),
          ),
        ),
      ],
    );
  }

  void _showLocationPicker(
    BuildContext context,
    String title,
    List<LocationModel> options,
    ValueChanged<LocationModel> onSelected,
  ) {
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có danh sách địa điểm.')));
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return _LocationPickerSheet(
          title: title,
          options: options,
          onSelected: onSelected,
          locationTitle: _locationTitle,
        );
      },
    );
  }
}

class _TimeSlotRow extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _TimeSlotRow({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text('Khung giờ', style: AppTextStyles.subtitle2)),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SearchableLocationField extends StatelessWidget {
  final String label;
  final LocationModel? value;
  final List<LocationModel> options;
  final VoidCallback onTap;

  const _SearchableLocationField({
    required this.label,
    required this.value,
    required this.options,
    required this.onTap,
  });

  static String _title(LocationModel loc) => loc.metadata?.title ?? loc.id;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: AppTextStyles.subtitle2)),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value != null ? _title(value!) : 'Chọn địa điểm',
                      style: AppTextStyles.body2.copyWith(
                        color: value != null ? null : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Icon(Icons.search, size: 20, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  final String title;
  final List<LocationModel> options;
  final ValueChanged<LocationModel> onSelected;
  final String Function(LocationModel) locationTitle;

  const _LocationPickerSheet({
    required this.title,
    required this.options,
    required this.onSelected,
    required this.locationTitle,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final TextEditingController _filterController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _filterController.addListener(() => setState(() => _query = _filterController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  List<LocationModel> get _filtered {
    if (_query.isEmpty) return widget.options;
    return widget.options.where((l) {
      final t = widget.locationTitle(l).toLowerCase();
      final a = l.metadata?.address?.toLowerCase() ?? '';
      return t.contains(_query) || a.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _filterController,
                decoration: InputDecoration(
                  hintText: 'Nhập để lọc...',
                  prefixIcon: const Icon(Icons.search, size: 22),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final loc = _filtered[i];
                  return ListTile(
                    leading: Icon(Icons.place_outlined, color: AppColors.primary, size: 22),
                    title: Text(widget.locationTitle(loc)),
                    subtitle: loc.metadata?.address != null && loc.metadata!.address!.isNotEmpty
                        ? Text(loc.metadata!.address!, style: AppTextStyles.caption)
                        : null,
                    onTap: () => widget.onSelected(loc),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
