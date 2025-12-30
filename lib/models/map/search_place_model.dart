class SearchPlaceResult {
  final String id;
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String? categoryCode;

  const SearchPlaceResult({
    required this.id,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.categoryCode,
  });

  factory SearchPlaceResult.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final coordinates = location['coordinates'] as List<dynamic>? ?? [0, 0];

    return SearchPlaceResult(
      id: json['id'] as String? ?? '',
      title: metadata['title'] as String? ?? 'Không có tên',
      address: metadata['address'] as String? ?? '',
      latitude: (coordinates.length > 1 ? coordinates[1] : 0).toDouble(),
      longitude: (coordinates.length > 0 ? coordinates[0] : 0).toDouble(),
      categoryCode: json['categoryCode'] as String?,
    );
  }
}

class SearchPlacesResponse {
  final List<SearchPlaceResult> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const SearchPlacesResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory SearchPlacesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];

    return SearchPlacesResponse(
      data: dataList
          .map(
            (item) => SearchPlaceResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
