class GetNearestPlaceDto {
  final double latitude;
  final double longitude;
  final int page;
  final int limit;
  final String? search;

  GetNearestPlaceDto({
    required this.latitude,
    required this.longitude,
    required this.page,
    required this.limit,
    this.search,
  });
}
