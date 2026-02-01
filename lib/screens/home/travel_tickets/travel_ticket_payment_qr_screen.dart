import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/ticket/booking_payment_model.dart';

/// Màn chuyển khoản VietQR: QR code + thông tin ngân hàng, số tiền, nội dung.
class TravelTicketPaymentQrScreen extends StatelessWidget {
  final BookingPaymentModel booking;

  const TravelTicketPaymentQrScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    final bankName = 'Ngân hàng TMCP Sài Gòn';
    final bankShortName = 'SCB';
    final accountNo = '1234567890';
    final accountName = 'CONG TY SGTour';
    final amount = booking.amountVnd.toInt();
    final transferContent = 'SGTour ${booking.typeLabel} ${booking.timeSlot}';

    final qrPayload = 'SGTour|$bankShortName|$accountNo|$accountName|$amount|$transferContent';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
        title: const Text('Chuyển khoản ngân hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quét mã QR bằng ứng dụng ngân hàng để chuyển khoản',
              style: AppTextStyles.body2.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: qrPayload,
                      version: QrVersions.auto,
                      size: 220,
                      gapless: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoRow('Ngân hàng', bankName),
                  _infoRow('Số tài khoản', accountNo),
                  _infoRow('Chủ tài khoản', accountName),
                  _infoRow('Số tiền', '${amount.toStringAsFixed(0)} đ', highlight: true),
                  _infoRow('Nội dung chuyển khoản', transferContent),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vui lòng nhập đúng nội dung chuyển khoản để vé được kích hoạt tự động.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: AppTextStyles.caption)),
          Expanded(
            child: SelectableText(
              value,
              style: AppTextStyles.body2.copyWith(
                fontWeight: highlight ? FontWeight.w600 : null,
                color: highlight ? AppColors.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
