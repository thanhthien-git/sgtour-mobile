import 'package:sgtour_mobile/enums/category.dart';

class Location {
  final double? latitude;
  final double? longitude;
  Location({this.latitude, this.longitude});
}

class LocationMetadata {
  final String title;
  final String? address;

  LocationMetadata({required this.title, this.address});
}

class LocationModel {
  final String id;
  final String? imageUrl;
  final Location? location;
  final String? category;
  final LocationMetadata? metadata;

  const LocationModel({
    required this.id,
    required this.imageUrl,
    this.location,
    this.metadata,
    this.category,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'].toString(),
      imageUrl: json['imageUrl'] as String?,
      metadata: LocationMetadata(
        title: (json['metadata']?['title'] as String?) ?? '',
        address: json['metadata']?['address'] as String?,
      ),

      location: Location(
        latitude: (json['location']?['latitude'] as num?)?.toDouble(),
        longitude: (json['location']?['longitude'] as num?)?.toDouble(),
      ),
      category: LocationCategoryX.getLabelFromCode(json['category'] as String?),
    );
  }
}
