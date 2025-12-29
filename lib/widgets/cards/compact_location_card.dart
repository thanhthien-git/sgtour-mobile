import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../models/location_model.dart';

class CompactLocationCard extends StatelessWidget {
  final LocationModel location;
  final LatLng? userPosition;
  final VoidCallback? onTap;

  const CompactLocationCard({
    super.key,
    required this.location,
    this.userPosition,
    this.onTap,
  });

  String _getDistance() {
    if (userPosition == null ||
        location.location?.latitude == null ||
        location.location?.longitude == null)
      return '';

    final distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      location.location!.latitude!,
      location.location!.longitude!,
    );
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280, // Chiều rộng cố định cho carousel
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Ảnh (Square bên trái)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: location.imageUrl ?? '',
                width: 100,
                height: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 20),
                ),
              ),
            ),

            // 2. Nội dung (Bên phải)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      location.metadata?.title ?? 'Unknown',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.category ?? 'General',
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (userPosition != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me,
                              size: 10,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _getDistance(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
