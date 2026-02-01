/// Loại vé: theo tour (tuyến cố định) hoặc theo cá nhân (tùy chọn điểm).
enum TravelTicketType { tour, personal }

/// Vé đang active (đã mua, còn hiệu lực).
class ActiveTicketModel {
  final String id;
  final TravelTicketType type;
  final String departureName;
  final List<String> stopNames;
  final String timeSlot;
  final String? validUntil;
  final String? qrCode;

  const ActiveTicketModel({
    required this.id,
    required this.type,
    required this.departureName,
    required this.stopNames,
    required this.timeSlot,
    this.validUntil,
    this.qrCode,
  });

  String get typeLabel => type == TravelTicketType.tour ? 'Vé theo tour' : 'Vé theo cá nhân';
  String get stopsDisplay => stopNames.isEmpty ? '—' : stopNames.join(' → ');
}

/// Vé đã mua trong lịch sử.
class HistoryTicketModel {
  final String id;
  final TravelTicketType type;
  final String departureName;
  final List<String> stopNames;
  final String timeSlot;
  final String usedAt;

  const HistoryTicketModel({
    required this.id,
    required this.type,
    required this.departureName,
    required this.stopNames,
    required this.timeSlot,
    required this.usedAt,
  });

  String get typeLabel => type == TravelTicketType.tour ? 'Vé theo tour' : 'Vé theo cá nhân';
  String get stopsDisplay => stopNames.isEmpty ? '—' : stopNames.join(' → ');
}

/// Một xe du lịch trong danh sách (theo khung giờ): tên/tuyến, số vé đã mua, số vé còn trống.
class TourBusModel {
  final String id;
  final String name;
  final String timeSlot;
  final int soldCount;
  final int availableCount;

  const TourBusModel({
    required this.id,
    required this.name,
    required this.timeSlot,
    required this.soldCount,
    required this.availableCount,
  });
}
