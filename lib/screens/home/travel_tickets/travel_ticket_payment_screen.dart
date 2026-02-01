import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/ticket/booking_payment_model.dart';
import 'package:sgtourcus/screens/home/travel_tickets/travel_ticket_payment_card_screen.dart';
import 'package:sgtourcus/screens/home/travel_tickets/travel_ticket_payment_qr_screen.dart';

enum PaymentMethod { cash, bankTransfer, card }

class TravelTicketPaymentScreen extends StatefulWidget {
  final BookingPaymentModel booking;

  const TravelTicketPaymentScreen({super.key, required this.booking});

  @override
  State<TravelTicketPaymentScreen> createState() => _TravelTicketPaymentScreenState();
}

class _TravelTicketPaymentScreenState extends State<TravelTicketPaymentScreen> {
  PaymentMethod _method = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final b = widget.booking;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
        title: const Text('Thanh toán'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _card(surfaceColor, borderColor, 'Thông tin vé', [
              _row('Loại vé', b.typeLabel),
              _row('Xuất phát', b.departureName),
              _row('Điểm dừng', b.stopsDisplay),
              _row('Khung giờ', b.timeSlot),
            ]),
            const SizedBox(height: 16),
            _card(surfaceColor, borderColor, 'Thông tin liên hệ', [
              _row('Họ tên', b.userName),
              _row('Số điện thoại', b.userPhone),
            ]),
            const SizedBox(height: 16),
            _card(surfaceColor, borderColor, 'Thanh toán', [
              _row('Số tiền', '${b.amountVnd.toStringAsFixed(0)} đ'),
              const SizedBox(height: 12),
              Text('Phương thức thanh toán', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.cash,
                groupValue: _method,
                onChanged: (v) => setState(() => _method = v!),
                activeColor: AppColors.primary,
                title: Row(children: [Icon(Icons.payments_outlined, color: _method == PaymentMethod.cash ? AppColors.primary : textSecondary, size: 22), const SizedBox(width: 12), const Text('Tiền mặt')]),
              ),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.bankTransfer,
                groupValue: _method,
                onChanged: (v) => setState(() => _method = v!),
                activeColor: AppColors.primary,
                title: Row(children: [Icon(Icons.qr_code_2_outlined, color: _method == PaymentMethod.bankTransfer ? AppColors.primary : textSecondary, size: 22), const SizedBox(width: 12), const Text('Chuyển khoản ngân hàng')]),
              ),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.card,
                groupValue: _method,
                onChanged: (v) => setState(() => _method = v!),
                activeColor: AppColors.primary,
                title: Row(children: [Icon(Icons.credit_card_outlined, color: _method == PaymentMethod.card ? AppColors.primary : textSecondary, size: 22), const SizedBox(width: 12), const Text('Thẻ Master/Visa')]),
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _onBuyTicket(b),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Mua vé'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Color surfaceColor, Color borderColor, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 12), ...children]),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 110, child: Text(label, style: AppTextStyles.caption)), Expanded(child: Text(value, style: AppTextStyles.body2))]),
    );
  }

  void _onBuyTicket(BookingPaymentModel b) {
    if (_method == PaymentMethod.cash) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt vé thành công. Thanh toán tiền mặt khi lên xe.')));
      Navigator.of(context).pop();
      return;
    }
    if (_method == PaymentMethod.bankTransfer) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => TravelTicketPaymentQrScreen(booking: b)));
      return;
    }
    if (_method == PaymentMethod.card) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => TravelTicketPaymentCardScreen(booking: b)));
    }
  }
}
