import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

/// Model for nearby location data
class NearbyLocation {
  final String id;
  final String name;
  final String address;
  final String? imageUrl;
  final double? distance; // in km

  const NearbyLocation({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    this.distance,
  });
}

/// Horizontal scrollable card list for nearby locations
class NearbyLocationCards extends StatelessWidget {
  final List<NearbyLocation> locations;
  final void Function(NearbyLocation)? onLocationTap;
  final double height;

  const NearbyLocationCards({
    super.key,
    required this.locations,
    this.onLocationTap,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: locations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _LocationCard(
            location: locations[index],
            onTap: () => onLocationTap?.call(locations[index]),
          );
        },
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final NearbyLocation location;
  final VoidCallback? onTap;

  const _LocationCard({required this.location, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 70,
                width: double.infinity,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: location.imageUrl != null
                    ? Image.network(
                        location.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      location.name,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.address,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 24),
    );
  }
}
