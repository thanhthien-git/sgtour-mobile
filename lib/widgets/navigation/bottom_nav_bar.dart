import 'package:flutter/material.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import '../../config/app_colors.dart';

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final VoidCallback? onCenterButtonTap;
  final IconData centerButtonIcon;

  static const double _navBarHeight = 80.0;
  static const double _fabSize = 72.0;
  static const double _notchMargin = 8.0;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onCenterButtonTap,
    this.centerButtonIcon = Icons.qr_code_scanner,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    if (onCenterButtonTap == null) {
      return _buildSimpleNavBar(isDark, backgroundColor);
    }

    final notchRadius = (_fabSize / 2) + _notchMargin;

    return SizedBox(
      height: _navBarHeight + MediaQuery.of(context).padding.bottom,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            top: -notchRadius,
            child: CustomPaint(
              painter: _NotchedNavBarPainter(
                backgroundColor: backgroundColor,
                notchRadius: notchRadius - 4, // Giảm đường kính
                shadowColor: Colors.black.withOpacity(0.1),
                topPadding: notchRadius,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SizedBox(
              height: _navBarHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildNavItems(isDark),
              ),
            ),
          ),
          Positioned(
            top: -(_fabSize / 2),
            child: _CenterFabButton(
              icon: centerButtonIcon,
              onTap: onCenterButtonTap!,
              size: _fabSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleNavBar(bool isDark, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: _navBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final centerIndex = items.length ~/ 2;
              if (index == centerIndex - 1) {
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _NavBarItem(
                          item: item,
                          isSelected: index == currentIndex,
                          onTap: () => onTap(index),
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: _fabSize + _notchMargin * 2),
                    ],
                  ),
                );
              } else {
                return Expanded(
                  child: _NavBarItem(
                    item: item,
                    isSelected: index == currentIndex,
                    onTap: () => onTap(index),
                    isDark: isDark,
                  ),
                );
              }
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(bool isDark) {
    final centerIndex = items.length ~/ 2;
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isSelected = i == currentIndex;

      widgets.add(
        Expanded(
          child: _NavBarItem(
            item: item,
            isSelected: isSelected,
            onTap: () => onTap(i),
            isDark: isDark,
          ),
        ),
      );

      if (i == centerIndex - 1) {
        widgets.add(SizedBox(width: _fabSize + _notchMargin * 2));
      }
    }

    return widgets;
  }
}

class _NotchedNavBarPainter extends CustomPainter {
  final Color backgroundColor;
  final double notchRadius;
  final Color shadowColor;
  final double topPadding;

  _NotchedNavBarPainter({
    required this.backgroundColor,
    required this.notchRadius,
    required this.shadowColor,
    required this.topPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    const double cornerRadius = 6;
    final centerX = size.width / 2;
    final navBarTop = topPadding;

    // Bán kính của vòng tròn ôm nút QR
    final arcRadius = notchRadius;

    final path = Path();

    // Bắt đầu từ góc trái
    path.moveTo(0, navBarTop);

    // Bo tròn góc trái của notch
    path.lineTo(centerX - arcRadius - cornerRadius, navBarTop);
    path.quadraticBezierTo(
      centerX - arcRadius - cornerRadius,
      navBarTop,
      centerX - arcRadius,
      navBarTop,
    );

    // Arc sâu giữa notch (giữ nguyên)
    path.arcToPoint(
      Offset(centerX + arcRadius, navBarTop),
      radius: Radius.circular(arcRadius),
      clockwise: false,
    );

    // Bo tròn góc phải của notch
    path.quadraticBezierTo(
      centerX + arcRadius + cornerRadius,
      navBarTop,
      centerX + arcRadius + cornerRadius,
      navBarTop,
    );

    // Line to top-right
    path.lineTo(size.width, navBarTop);

    // Right side, bottom, and left side
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow first
    canvas.drawPath(path.shift(const Offset(0, -1)), shadowPaint);

    // Draw background
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedNavBarPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.topPadding != topPadding;
  }
}

class _CenterFabButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CenterFabButton({
    required this.icon,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.45),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final currentColor = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutQuad,
                height: 3,
                width: isSelected ? 80 : 0,
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey(isSelected),
                    color: currentColor,
                    size: 26,
                  ),
                ),

                const SizedBox(height: 4),

                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTextStyles.subtitle2.copyWith(
                    color: currentColor,
                    fontSize: 8,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
