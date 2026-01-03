import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../config/app_colors.dart';

class LocationMarker extends StatefulWidget {
  final String label;
  final String? imageUrl;
  final bool isSelected;

  const LocationMarker({
    super.key,
    required this.label,
    this.imageUrl,
    this.isSelected = false,
  });

  @override
  State<LocationMarker> createState() => _LocationMarkerState();
}

class _LocationMarkerState extends State<LocationMarker> {
  bool _hasTimedOut = false;
  bool _imageLoaded = false;
  Timer? _timeoutTimer;
  ImageProvider? _cachedImageProvider;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      // Create cached image provider
      _cachedImageProvider = CachedNetworkImageProvider(
        widget.imageUrl!,
        maxWidth: 80,
        maxHeight: 80,
      );

      // Check if image is already in cache
      _checkImageCache();

      _timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (mounted && !_imageLoaded) {
          setState(() {
            _hasTimedOut = true;
          });
        }
      });
    }
  }

  Future<void> _checkImageCache() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) return;

    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(
        widget.imageUrl!,
      );
      if (fileInfo != null && mounted) {
        setState(() {
          _imageLoaded = true;
        });
        _timeoutTimer?.cancel();
      }
    } catch (e) {
      // Ignore cache check errors
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RepaintBoundary(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pin with image as circle
            SizedBox(
              width: 48,
              height: 58,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Pin point background
                  Positioned(
                    top: 32,
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      painter: _PinPointPainter(
                        color: widget.isSelected
                            ? AppColors.primary
                            : const Color(0xFF34A853),
                      ),
                      child: const SizedBox(width: 48, height: 26),
                    ),
                  ),
                  // Circle with image and border
                  Positioned(
                    top: 0,
                    left: 4,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: widget.isSelected
                              ? AppColors.primary
                              : const Color(0xFF34A853),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _hasTimedOut
                            ? Container(
                                color: widget.isSelected
                                    ? AppColors.primary.withOpacity(0.2)
                                    : const Color(0xFF34A853).withOpacity(0.2),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: widget.isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF34A853),
                                  size: 20,
                                ),
                              )
                            : (widget.imageUrl != null &&
                                      widget.imageUrl!.isNotEmpty &&
                                      _cachedImageProvider != null
                                  ? Image(
                                      image: _cachedImageProvider!,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                      frameBuilder:
                                          (
                                            context,
                                            child,
                                            frame,
                                            wasSynchronouslyLoaded,
                                          ) {
                                            if (wasSynchronouslyLoaded ||
                                                frame != null) {
                                              if (!_imageLoaded && mounted) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      if (mounted) {
                                                        setState(() {
                                                          _imageLoaded = true;
                                                        });
                                                        _timeoutTimer?.cancel();
                                                      }
                                                    });
                                              }
                                              return child;
                                            }
                                            return Container(
                                              color: Colors.grey.shade100,
                                              child: _imageLoaded
                                                  ? child
                                                  : const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              Color(0xFF34A853),
                                                            ),
                                                      ),
                                                    ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            _timeoutTimer?.cancel();
                                            return Container(
                                              color: widget.isSelected
                                                  ? AppColors.primary
                                                        .withOpacity(0.2)
                                                  : const Color(
                                                      0xFF34A853,
                                                    ).withOpacity(0.2),
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: widget.isSelected
                                                    ? AppColors.primary
                                                    : const Color(0xFF34A853),
                                                size: 20,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      color: widget.isSelected
                                          ? AppColors.primary
                                          : const Color(0xFF34A853),
                                      child: const Icon(
                                        Icons.place,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Label at bottom
            Container(
              constraints: const BoxConstraints(maxWidth: 100),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pin point painter (bottom triangle part)
class _PinPointPainter extends CustomPainter {
  final Color color;

  _PinPointPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();

    final topWidth =
        size.width * 0.6; // Width at top where it connects to circle
    final centerX = size.width / 2;

    path.moveTo(centerX - topWidth / 2, 0); // Top left
    path.lineTo(centerX + topWidth / 2, 0); // Top right
    path.lineTo(centerX, size.height); // Bottom point
    path.close();

    // Draw shadow first
    canvas.drawPath(path, shadowPaint);
    // Draw the shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinPointPainter oldDelegate) =>
      oldDelegate.color != color;
}
