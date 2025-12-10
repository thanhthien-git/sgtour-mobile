/// Model for location/place data
class LocationModel {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? reviewCount;

  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.rating,
    this.reviewCount,
  });

  /// Factory constructor for creating from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      rating: json['rating'] as double?,
      reviewCount: json['reviewCount'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  /// Copy with method for immutability
  LocationModel copyWith({
    String? id,
    String? name,
    String? address,
    String? imageUrl,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
