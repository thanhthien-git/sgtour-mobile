import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/models/map/get_nearest_place_dto.dart';
import 'package:sgtour_mobile/services/location_service.dart';
import 'package:sgtour_mobile/services/map_service.dart';
import '../../models/location_model.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/base_scaffold.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/cards/location_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Position? _currentUserPosition;
  final List<LocationModel> _nearbyLocations = [];

  final ScrollController _scrollController = ScrollController();

  static const int _limit = 10;
  int _page = 1;

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isFetching || !_hasMore) return;
    if (_scrollController.position.extentAfter < 300) {
      _fetchNearestPlaces(isLoadMore: true);
    }
  }

  Future<void> _initData({bool isRefresh = false}) async {
    try {
      if (!isRefresh && mounted) setState(() => _isLoadingInitial = true);

      final position = await LocationService.getCurrentPosition();

      if (!mounted) return;
      setState(() {
        _currentUserPosition = position;
      });

      if (position != null) {
        debugPrint(
          "✅ Location found: ${position.latitude}, ${position.longitude}",
        );
        await _fetchNearestPlaces(isLoadMore: false, isRefresh: isRefresh);
      } else {
        debugPrint("⚠️ Location is NULL");
        setState(() => _isLoadingInitial = false);
      }
    } catch (e) {
      debugPrint('❌ Init Data Error: $e');
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  Future<void> _fetchNearestPlaces({
    required bool isLoadMore,
    bool isRefresh = false,
  }) async {
    // Guard clause: Chặn nếu đang fetch hoặc đã hết dữ liệu
    if (_isFetching && !isRefresh) return;
    if (!_hasMore && isLoadMore) {
      debugPrint("⛔ Đã hết dữ liệu (HasMore = false), không load nữa.");
      return;
    }

    setState(() {
      _isFetching = true;
      if (isLoadMore) _isLoadingMore = true;
    });

    try {
      debugPrint("🚀 Bắt đầu gọi API Page: $_page");

      final dto = GetNearestPlaceDto(
        latitude: _currentUserPosition!.latitude,
        longitude: _currentUserPosition!.longitude,
        page: _page,
        limit: _limit,
      );

      final newLocations = await MapService.getNearestLocations(dto);

      debugPrint("✅ API trả về: ${newLocations.length} địa điểm.");

      if (!mounted) return;

      setState(() {
        if (newLocations.length < _limit) {
          _hasMore = false;
          debugPrint("🏁 Dữ liệu trả về ít hơn limit -> Đánh dấu HẾT DỮ LIỆU.");
        }

        if (_page == 1) {
          _nearbyLocations.clear();
        }

        _nearbyLocations.addAll(newLocations);

        if (newLocations.isNotEmpty) {
          _page++;
        }
      });
    } catch (e) {
      debugPrint('❌ API Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
          _isLoadingInitial = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _page = 1;
            _hasMore = true;
            await _initData(isRefresh: true);
          },
          child: _isLoadingInitial
              ? const Center(child: CircularProgressIndicator())
              : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    int itemCount = 1 + _nearbyLocations.length + (_isLoadingMore ? 1 : 0);

    // Trường hợp chưa có dữ liệu và không phải đang load lần đầu
    if (_nearbyLocations.isEmpty && !_isLoadingInitial) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildHeader(),
          const SizedBox(height: 100),
          Center(
            child: Text(
              'No places found',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }

        final dataIndex = index - 1;

        if (dataIndex >= _nearbyLocations.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          );
        }

        // 3. Item Location
        final location = _nearbyLocations[dataIndex];
        return LocationCard(
          currentUserPosition: _currentUserPosition,
          location: location,
          onTap: () => _handleLocationTap(location),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        SearchBarWidget(
          hintText: context.l10n.ai_input_hint,
          onTap: _handleSearchTap,
          onAiTap: _handleAiTap,
        ),

        const SizedBox(height: 16),
        SectionHeader(title: context.l10n.home_exploreNearby),
      ],
    );
  }

  void _handleSearchTap() {
    debugPrint('Search tapped');
  }

  void _handleAiTap() {
    debugPrint('AI tapped');
  }

  void _handleLocationTap(LocationModel location) {
    // Navigate logic
  }
}
