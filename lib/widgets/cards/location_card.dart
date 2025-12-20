import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../models/location_model.dart';

class LocationCard extends StatelessWidget {
  final LocationModel location;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry contentPadding;
  final Position? currentUserPosition;

  const LocationCard({
    super.key,
    required this.location,
    this.onTap,
    this.currentUserPosition,
    this.height,
    this.width,
    this.contentPadding = const EdgeInsets.all(12.0),
  });

  List<BoxShadow> _getGoogleStyleShadows(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(0, 4),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];
    }
  }

  String _calculateDistance() {
    if (currentUserPosition == null ||
        location.location!.latitude == null ||
        location.location!.longitude == null) {
      return '---'; //
    }

    double distanceInMeters = Geolocator.distanceBetween(
      currentUserPosition!.latitude,
      currentUserPosition!.longitude,
      location.location!.latitude!,
      location.location!.longitude!,
    );

    double distanceInKm = distanceInMeters / 1000;
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final imageSize = height ?? 104.0;

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: location.metadata?.title ?? "Unknown",
        button: true,
        child: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _getGoogleStyleShadows(isDark),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: _buildCachedImage(isDark),
                ),
                Expanded(child: _buildContentDetails(isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCachedImage(bool isDark) {
    Widget placeholderWidget(IconData icon) {
      return Container(
        color: isDark ? Colors.grey[800] : AppColors.inputBackground,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isDark ? Colors.grey[500] : AppColors.textTertiary,
          size: 24,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: location.imageUrl ?? '',
      fit: BoxFit.cover,

      placeholder: (context, url) => placeholderWidget(Icons.image),
      errorWidget: (context, url, error) =>
          placeholderWidget(Icons.image_not_supported_outlined),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeOut,
    );
  }

  Widget _buildContentDetails(bool isDark) {
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    final captionStyle = AppTextStyles.caption.copyWith(
      color: secondaryTextColor,
      height: 1.2,
    );

    final String distanceText = _calculateDistance();

    const double iconSize = 14.0;
    const double iconSpacing = 4.0;

    return Padding(
      padding: contentPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 150;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                location.metadata?.title ?? 'Unknown',
                style: AppTextStyles.subtitle2.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              Row(
                children: [
                  if (!isCompact) ...[
                    Icon(
                      Icons.location_on_outlined,
                      color: secondaryTextColor,
                      size: iconSize,
                    ),
                    const SizedBox(width: iconSpacing),
                  ],
                  Expanded(
                    child: Text(
                      distanceText,
                      style: captionStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  if (!isCompact) ...[
                    Icon(
                      Icons.category_outlined,
                      color: secondaryTextColor,
                      size: iconSize,
                    ),
                    const SizedBox(width: iconSpacing),
                  ],
                  Expanded(
                    child: Text(
                      location.category ?? 'Khác',
                      style: captionStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
