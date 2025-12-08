class TourModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviewCount;
  final String location;
  final int duration; // in hours
  final DateTime createdAt;

  TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.duration,
    required this.createdAt,
  });

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      location: json['location'] ?? '',
      duration: json['duration'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
