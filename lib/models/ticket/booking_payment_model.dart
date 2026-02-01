/// Loại vé đặt: tour hoặc cá nhân.
enum BookingType { tour, personal }

/// Dữ liệu đặt vé gửi sang màn Thanh toán.
class BookingPaymentModel {
  final BookingType type;
  final String departureName;
  final List<String> stopNames;
  final String timeSlot;
  final double amountVnd;
  final String userName;
  final String userPhone;

  const BookingPaymentModel({
    required this.type,
    required this.departureName,
    required this.stopNames,
    required this.timeSlot,
    required this.amountVnd,
    required this.userName,
    required this.userPhone,
  });

  String get typeLabel => type == BookingType.tour ? 'Vé theo tour' : 'Vé cá nhân';
  String get stopsDisplay => stopNames.isEmpty ? '—' : stopNames.join(' → ');
}
