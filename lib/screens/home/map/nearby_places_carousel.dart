import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/models/location_model.dart';
import 'package:sgtour_mobile/models/map/get_nearest_place_dto.dart';
import 'package:sgtour_mobile/screens/home/map/nearby_place_skeleton_card.dart';
import 'package:sgtour_mobile/services/map/map_service.dart';
import 'package:sgtour_mobile/widgets/cards/compact_location_card.dart';

class NearbyPlacesCarousel extends StatefulWidget {
  final LatLng? userLocation;
  final ValueChanged<LocationModel>? onPlaceTap;

  const NearbyPlacesCarousel({
    super.key,
    required this.userLocation,
    this.onPlaceTap,
  });

  @override
  State<NearbyPlacesCarousel> createState() => _NearbyPlacesCarouselState();
}

class _NearbyPlacesCarouselState extends State<NearbyPlacesCarousel> {
  List<LocationModel> _places = [];
  LatLng? _lastFetchLocation;
  bool _loading = false;

  static const double _minDistance = 20;

  @override
  void didUpdateWidget(covariant NearbyPlacesCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newLoc = widget.userLocation;
    if (newLoc == null) return;

    if (_lastFetchLocation == null) {
      _fetch(newLoc);
      return;
    }

    final distance = Geolocator.distanceBetween(
      _lastFetchLocation!.latitude,
      _lastFetchLocation!.longitude,
      newLoc.latitude,
      newLoc.longitude,
    );

    if (distance >= _minDistance) {
      _fetch(newLoc);
    }
  }

  Future<void> _fetch(LatLng location) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final dto = GetNearestPlaceDto(
        latitude: location.latitude,
        longitude: location.longitude,
        page: 1,
        limit: 10,
      );

      final result = await MapService.getNearestLocations(dto);

      if (!mounted) return;
      setState(() {
        _places = result;
        _lastFetchLocation = location;
      });
    } catch (e) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userLocation == null) {
      return const SizedBox.shrink();
    }

    if (_loading && _places.isEmpty) {
      return _buildSkeleton();
    }

    if (_places.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildList();
  }

  Widget _buildList() {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 24;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding,
      child: SizedBox(
        height: 110,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _places.length,
          itemBuilder: (context, index) {
            final place = _places[index];
            return CompactLocationCard(
              location: place,
              userPosition: widget.userLocation,
              onTap: () => widget.onPlaceTap?.call(place),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 24;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding,
      child: SizedBox(
        height: 110,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (_, __) => const NearbyPlaceSkeletonCard(),
        ),
      ),
    );
  }
}
