/// Lightweight model for top-rated place in community (địa điểm rating cao)
class TopRatedPlaceModel {
  final String id;
  final String name;
  final double rating;
  final String? imageUrl;
  final String? address;

  const TopRatedPlaceModel({
    required this.id,
    required this.name,
    this.rating = 0,
    this.imageUrl,
    this.address,
  });

  factory TopRatedPlaceModel.fromJson(Map<String, dynamic> json) {
    return TopRatedPlaceModel(
      id: (json['id'] ?? json['placeId'] ?? json['markerId'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? json['displayImage'] as String?,
      address: json['address'] as String?,
    );
  }
}
