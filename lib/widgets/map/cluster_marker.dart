import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class ClusterMarker extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const ClusterMarker({super.key, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = _getClusterSize(count);
    final fontSize = _getFontSize(count);

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: RepaintBoundary(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _formatCount(count),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getClusterSize(int count) {
    if (count < 10) return 50;
    if (count < 50) return 60;
    if (count < 100) return 70;
    return 80;
  }

  double _getFontSize(int count) {
    if (count < 10) return 14;
    if (count < 50) return 16;
    if (count < 100) return 18;
    return 20;
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 10000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000).round()}k';
  }
}
