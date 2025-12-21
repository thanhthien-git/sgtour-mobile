// 1. Giữ nguyên Enum của bạn
enum LocationCategory {
  van_hoa,
  du_lich,
  khach_san,
  am_thuc,
  tham_quan,
  bao_tang,
  giai_tri,
  shopping,
  su_kien,
  giao_thong,
  cham_soc_suc_khoe,
  nghi_duong,
}

// 2. Giữ nguyên Map label
const Map<LocationCategory, String> _locationCategoryLabels = {
  LocationCategory.van_hoa: 'Văn hóa',
  LocationCategory.du_lich: 'Du lịch',
  LocationCategory.khach_san: 'Khách sạn',
  LocationCategory.am_thuc: 'Ẩm thực',
  LocationCategory.tham_quan: 'Tham quan',
  LocationCategory.bao_tang: 'Bảo tàng',
  LocationCategory.giai_tri: 'Giải trí',
  LocationCategory.shopping: 'Mua sắm',
  LocationCategory.su_kien: 'Sự kiện',
  LocationCategory.giao_thong: 'Giao thông',
  LocationCategory.cham_soc_suc_khoe: 'Chăm sóc sức khỏe',
  LocationCategory.nghi_duong: 'Nghỉ dưỡng',
};

extension LocationCategoryX on LocationCategory {
  String get label => _locationCategoryLabels[this]!;
  static String getLabelFromCode(String? code) {
    if (code == null || code.isEmpty) return 'Khác';

    try {
      final type = LocationCategory.values.firstWhere((e) => e.name == code);
      return type.label;
    } catch (_) {
      return 'Khác';
    }
  }
}
