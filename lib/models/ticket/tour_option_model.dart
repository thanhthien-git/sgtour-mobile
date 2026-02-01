/// Danh mục bến xuất phát / bến dừng dùng cho vé theo tour.
class TourOptionModel {
  final String id;
  final String name;
  final String? address;

  const TourOptionModel({required this.id, required this.name, this.address});
}
