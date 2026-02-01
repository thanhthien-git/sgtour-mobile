import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/ticket/travel_ticket_model.dart';
import 'package:sgtourcus/screens/home/travel_tickets/travel_ticket_book_screen.dart';

/// Trang Vé du lịch: nút Mua vé (popup), chọn khung giờ, danh sách xe du lịch, vé active, lịch sử.
class TravelTicketsScreen extends StatefulWidget {
  const TravelTicketsScreen({super.key});

  @override
  State<TravelTicketsScreen> createState() => _TravelTicketsScreenState();
}

class _TravelTicketsScreenState extends State<TravelTicketsScreen> {
  static const List<String> _timeSlots = [
    '06:00 – 08:00',
    '08:00 – 10:00',
    '10:00 – 12:00',
    '12:00 – 14:00',
    '14:00 – 16:00',
    '16:00 – 18:00',
  ];

  String _selectedTimeSlot = _timeSlots.first;

  /// Mock: danh sách xe theo khung giờ (số vé đã mua, còn trống).
  static List<TourBusModel> _mockBusesForSlot(String slot) {
    return [
      TourBusModel(id: '1', name: 'Tuyến Bến Thành – Chợ Lớn', timeSlot: slot, soldCount: 12, availableCount: 28),
      TourBusModel(id: '2', name: 'Tuyến Miền Đông – Miền Tây', timeSlot: slot, soldCount: 8, availableCount: 32),
      TourBusModel(id: '3', name: 'Tuyến Sân bay – Bến xe', timeSlot: slot, soldCount: 25, availableCount: 15),
      TourBusModel(id: '4', name: 'Tuyến An Sương – Quận 1', timeSlot: slot, soldCount: 5, availableCount: 35),
      TourBusModel(id: '5', name: 'Tuyến Bình Chánh – Thủ Đức', timeSlot: slot, soldCount: 18, availableCount: 22),
      TourBusModel(id: '6', name: 'Tuyến Hóc Môn – Quận 7', timeSlot: slot, soldCount: 3, availableCount: 37),
    ];
  }

  List<TourBusModel> get _busList => _mockBusesForSlot(_selectedTimeSlot);

  // Mock data
  final List<ActiveTicketModel> _activeTickets = [
    const ActiveTicketModel(
      id: 'a1',
      type: TravelTicketType.tour,
      departureName: 'Bến xe Miền Đông',
      stopNames: ['Bến Thành', 'Chợ Lớn'],
      timeSlot: '08:00 – 10:00',
      validUntil: '28/02/2025',
    ),
  ];

  final List<HistoryTicketModel> _historyTickets = [
    const HistoryTicketModel(
      id: 'h1',
      type: TravelTicketType.tour,
      departureName: 'Bến xe Miền Tây',
      stopNames: ['Bến xe Miền Đông'],
      timeSlot: '10:00 – 12:00',
      usedAt: '15/01/2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
        title: Text('Vé du lịch', style: AppTextStyles.heading5.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBuyTicketSection(surfaceColor, borderColor),
              const SizedBox(height: 20),
              _buildTimeSlotAndBusList(context, surfaceColor, borderColor, textSecondary),
              const SizedBox(height: 24),
              _buildActiveSection(surfaceColor, borderColor, textSecondary),
              const SizedBox(height: 24),
              _buildHistorySection(surfaceColor, borderColor, textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuyTicketSection(Color surfaceColor, Color borderColor) {
    return _SectionCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      title: 'Danh mục vé',
      icon: Icons.confirmation_number_outlined,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TravelTicketBookScreen()),
            );
          },
          icon: const Icon(Icons.add_shopping_cart_outlined, size: 22),
          label: const Text('Mua vé'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotAndBusList(BuildContext context, Color surfaceColor, Color borderColor, Color textSecondary) {
    return _SectionCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      title: 'Danh sách xe du lịch',
      icon: Icons.directions_bus_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(width: 100, child: Text('Khung thời gian', style: AppTextStyles.subtitle2)),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTimeSlot,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: _timeSlots.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() {
                    if (v != null) _selectedTimeSlot = v;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Xe / Tuyến', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600))),
                      SizedBox(width: 56, child: Text('Đã mua', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                      SizedBox(width: 56, child: Text('Còn trống', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5 * 40.0,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _busList.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
                    itemBuilder: (_, i) {
                      final bus = _busList[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(bus.name, style: AppTextStyles.body2.copyWith(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                            SizedBox(width: 56, child: Text('${bus.soldCount}', style: AppTextStyles.body2, textAlign: TextAlign.center)),
                            SizedBox(width: 56, child: Text('${bus.availableCount}', style: AppTextStyles.body2.copyWith(color: AppColors.primary), textAlign: TextAlign.center)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSection(Color surfaceColor, Color borderColor, Color textSecondary) {
    return _SectionCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      title: 'Vé đang active',
      icon: Icons.check_circle_outline,
      child: _activeTickets.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 48, color: textSecondary),
                    const SizedBox(height: 8),
                    Text('Chưa có vé đang active', style: AppTextStyles.body2.copyWith(color: textSecondary)),
                  ],
                ),
              ),
            )
          : Column(
              children: _activeTickets.map((t) => _TicketCard(active: t, textSecondary: textSecondary)).toList(),
            ),
    );
  }

  Widget _buildHistorySection(Color surfaceColor, Color borderColor, Color textSecondary) {
    return _SectionCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      title: 'Lịch sử vé đã mua',
      icon: Icons.history,
      child: _historyTickets.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: textSecondary),
                    const SizedBox(height: 8),
                    Text('Chưa có lịch sử', style: AppTextStyles.body2.copyWith(color: textSecondary)),
                  ],
                ),
              ),
            )
          : Column(
              children: _historyTickets.map((t) => _HistoryTicketCard(ticket: t, textSecondary: textSecondary)).toList(),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Color surfaceColor;
  final Color borderColor;
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.surfaceColor,
    required this.borderColor,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Text(title, style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), child: child),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final ActiveTicketModel active;
  final Color textSecondary;

  const _TicketCard({required this.active, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(active.typeLabel, style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
              const Spacer(),
              if (active.validUntil != null)
                Text('HSD: ${active.validUntil}', style: AppTextStyles.caption.copyWith(color: textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Xuất phát: ${active.departureName}', style: AppTextStyles.body2),
          Text('Điểm dừng: ${active.stopsDisplay}', style: AppTextStyles.body2.copyWith(color: textSecondary, fontSize: 14)),
          Text('Khung giờ: ${active.timeSlot}', style: AppTextStyles.caption.copyWith(color: textSecondary)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code, size: 20),
              label: const Text('Xem mã vé'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTicketCard extends StatelessWidget {
  final HistoryTicketModel ticket;
  final Color textSecondary;

  const _HistoryTicketCard({required this.ticket, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(ticket.typeLabel, style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Đã dùng: ${ticket.usedAt}', style: AppTextStyles.caption.copyWith(color: textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Text('${ticket.departureName} → ${ticket.stopsDisplay}', style: AppTextStyles.body2.copyWith(fontSize: 14)),
          Text('Khung giờ: ${ticket.timeSlot}', style: AppTextStyles.caption.copyWith(color: textSecondary)),
        ],
      ),
    );
  }
}
