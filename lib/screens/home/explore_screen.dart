import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/models/map/get_nearest_place_dto.dart';
import 'package:sgtour_mobile/repository/place_repository.dart';
import 'package:sgtour_mobile/services/location_service.dart';
import 'package:sgtour_mobile/services/map_service.dart';
import 'package:sgtour_mobile/widgets/place/place_widgets.dart';
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
  final MapRepository _mapRepo = MapRepository();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
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
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (_searchQuery != query) {
        setState(() {
          _searchQuery = query;
          _page = 1;
          _hasMore = true;
        });
        _fetchNearestPlaces(isLoadMore: false);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isFetching || !_hasMore) return;
    if (_scrollController.position.extentAfter < 300) {
      _fetchNearestPlaces(isLoadMore: true);
    }
  }

  Future<void> _onPlaceTap(String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final fullPlace = await _mapRepo.getPlaceDetail(id);
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

  Future<void> _initData({bool isRefresh = false}) async {
    try {
      if (!isRefresh && mounted) setState(() => _isLoadingInitial = true);

      final position = await LocationService.getLastKnownPosition();

      if (!mounted) return;
      setState(() {
        _currentUserPosition = position;
      });

      if (position != null) {
        await _fetchNearestPlaces(isLoadMore: false, isRefresh: isRefresh);
      } else {
        setState(() => _isLoadingInitial = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  Future<void> _fetchNearestPlaces({
    required bool isLoadMore,
    bool isRefresh = false,
  }) async {
    if (_isFetching && !isRefresh) return;
    if (!_hasMore && isLoadMore) return;

    setState(() {
      _isFetching = true;
      if (isLoadMore) _isLoadingMore = true;
      if (!isLoadMore && !isRefresh) _isLoadingInitial = true;
    });

    try {
      final dto = GetNearestPlaceDto(
        latitude: _currentUserPosition!.latitude,
        longitude: _currentUserPosition!.longitude,
        page: _page,
        limit: _limit,
        search: _searchQuery,
      );

      final newLocations = await MapService.getNearestLocations(dto);

      if (!mounted) return;

      setState(() {
        if (_page == 1) _nearbyLocations.clear();

        _nearbyLocations.addAll(newLocations);
        _hasMore = newLocations.length >= _limit;
        if (newLocations.isNotEmpty) _page++;
      });
    } catch (e) {
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildHeader(),
            ),

            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_nearbyLocations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 16),
          SectionHeader(
            title: _searchQuery.isEmpty
                ? context.l10n.home_exploreNearby
                : context.l10n.search_result_for(_searchQuery),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Center(child: Text('No places found')),
        ],
      );
    }

    int itemCount = 1 + _nearbyLocations.length + (_isLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 16);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return SectionHeader(
            title: _searchQuery.isEmpty
                ? context.l10n.home_exploreNearby
                : context.l10n.search_result_for(_searchQuery),
          );
        }

        final dataIndex = index - 1;

        if (dataIndex >= _nearbyLocations.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          );
        }

        final location = _nearbyLocations[dataIndex];
        return LocationCard(
          currentUserPosition: _currentUserPosition,
          location: location,
          onTap: () => _onPlaceTap(location.id),
        );
      },
    );
  }

  Widget _buildHeader() {
    return SearchBarWidget(
      controller: _searchController,
      hintText: context.l10n.ai_input_hint,
      onChanged: _onSearchChanged,
      readOnly: false,
    );
  }
}
