class PlaceMetadata {
  final String title;
  final String address;

  const PlaceMetadata({required this.title, required this.address});

  factory PlaceMetadata.fromJson(Map<String, dynamic> json) {
    return PlaceMetadata(
      title: json['title'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}
