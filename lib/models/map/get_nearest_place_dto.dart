class GetNearestPlaceDto {
  final double latitude;
  final double longitude;
  final int page;
  final int limit;

  GetNearestPlaceDto({
    required this.latitude,
    required this.longitude,
    required this.page,
    required this.limit,
  });
  Map<String, dynamic> toQuery() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'page': page,
      'limit': limit,
    };
  }
}
