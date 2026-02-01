import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/screens/home/travel_tickets/travel_ticket_book_screen.dart';

/// Nội dung tab "Chương trình": điểm mua vé, chương trình khuyến mãi, xe du lịch nội thành.
class ProgramsContent extends StatelessWidget {
  const ProgramsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final inputBg = isDark ? AppColors.inputBackgroundDark : AppColors.inputBackground;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return RefreshIndicator(
      onRefresh: () async {},
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTicketSection(context, surfaceColor, inputBg, borderColor, textSecondary),
            const SizedBox(height: 20),
            _buildPromotionsSection(surfaceColor, inputBg, borderColor, textSecondary),
            const SizedBox(height: 20),
            _buildCityBusesSection(surfaceColor, inputBg, borderColor, textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketSection(BuildContext context, Color surfaceColor, Color inputBg, Color borderColor, Color textSecondary) {
    const points = [
      {'name': 'Bến xe Miền Đông', 'address': '292 Đinh Bộ Lĩnh, Bình Thạnh'},
      {'name': 'Bến xe Miền Tây', 'address': 'An Lạc, Bình Tân'},
      {'name': 'Bến xe An Sương', 'address': 'Quốc lộ 22, Hóc Môn'},
    ];

    return _SectionCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      title: 'Các điểm mua vé',
      icon: Icons.confirmation_number_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...points.map((p) => _ListTileRow(
                icon: Icons.location_on_outlined,
                title: p['name']!,
                subtitle: p['address'] ?? '',
                textSecondary: textSecondary,
              )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TravelTicketBookScreen()),
                );
              },
              icon: const Icon(Icons.add_shopping_cart_outlined, size: 20),
              label: const Text('Mua vé'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsSection(Color surfaceColor, Color inputBg, Color borderColor, Color textSecondary) {
    const items = [
      {'title': 'Giảm 20% vé tháng 2', 'desc': 'Áp dụng tuyến nội thành', 'until': 'Hết 28/02'},
      {'title': 'Combo 2 người – ưu đãi 15%', 'desc': 'Mua 2 vé trở lên cùng tuyến', 'until': 'Hết 15/03'},
    ];

    return _SectionCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      title: 'Chương trình, khuyến mãi',
      icon: Icons.local_offer_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PromoCard(
            title: e['title']!,
            desc: e['desc']!,
            until: e['until']!,
            textSecondary: textSecondary,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCityBusesSection(Color surfaceColor, Color inputBg, Color borderColor, Color textSecondary) {
    const buses = [
      {'line': 'Tuyến 01', 'route': 'Bến Thành – Chợ Lớn'},
      {'line': 'Tuyến 52', 'route': 'Bến xe Miền Đông – Bến xe Miền Tây'},
      {'line': 'Tuyến 109', 'route': 'Sân bay Tân Sơn Nhất – Bến xe Miền Đông'},
    ];

    return _SectionCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      title: 'Xe du lịch nội thành phố',
      icon: Icons.directions_bus_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buses.map((b) => _ListTileRow(
              icon: Icons.directions_bus,
              title: b['line']!,
              subtitle: b['route'] ?? '',
              textSecondary: textSecondary,
            )).toList(),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
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
                Text(
                  title,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ListTileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textSecondary;

  const _ListTileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.body2.copyWith(color: textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String desc;
  final String until;
  final Color textSecondary;

  const _PromoCard({
    required this.title,
    required this.desc,
    required this.until,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(desc, style: AppTextStyles.body2.copyWith(color: textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(until, style: AppTextStyles.caption.copyWith(color: textSecondary)),
        ],
      ),
    );
  }
}
