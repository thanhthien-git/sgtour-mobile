import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../models/place/place_models.dart';
import '../../enums/enums.dart';
import 'place_image_gallery.dart';
import 'place_language_switcher.dart';

class PlaceDetailSheet extends StatefulWidget {
  final Place place;
  final VoidCallback? onClose;

  const PlaceDetailSheet({super.key, required this.place, this.onClose});

  static Future<void> show(BuildContext context, Place place) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black38,
      builder: (context) => PlaceDetailSheet(place: place),
    );
  }

  @override
  State<PlaceDetailSheet> createState() => _PlaceDetailSheetState();
}

class _PlaceDetailSheetState extends State<PlaceDetailSheet> {
  late PlaceLanguage _selectedLanguage;
  late PlaceTranslation? _currentTranslation;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.place.defaultLanguage;
    _currentTranslation = widget.place.getTranslation(_selectedLanguage);
  }

  void _onLanguageChanged(PlaceLanguage language) {
    setState(() {
      _selectedLanguage = language;
      _currentTranslation = widget.place.getTranslation(language);
    });
  }

  Future<void> _openGoogleMapsDirection() async {
    final lat = widget.place.location.latitude;
    final lng = widget.place.location.longitude;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Image gallery
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: PlaceImageGallery(
                          imageUrls: widget.place.imageUrls,
                          height: screenHeight * 0.28,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    // Header (title, address, language)
                    SliverToBoxAdapter(child: _buildHeader(isDark)),

                    // Dynamic content sections
                    SliverToBoxAdapter(child: _buildDynamicContent(isDark)),
                  ],
                ),
              ),

              // Direction button
              _buildDirectionButton(isDark, bottomPadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    final translation = _currentTranslation;
    final title = translation?.title ?? widget.place.title;
    final address = translation?.address ?? widget.place.address;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and language switcher
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PlaceLanguageSwitcher(
                selectedLanguage: _selectedLanguage,
                availableLanguages: widget.place.availableLanguages,
                onLanguageChanged: _onLanguageChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: AppTextStyles.body2.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicContent(bool isDark) {
    final translation = _currentTranslation;
    if (translation == null) return const SizedBox.shrink();

    final contentItems = translation.content
        .where((c) => c.key != 'title' && c.key != 'address')
        .toList();

    if (contentItems.isEmpty) return const SizedBox.shrink();

    final dividerColor = isDark ? Colors.grey[800] : Colors.grey[200];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < contentItems.length; i++) ...[
            _buildContentItem(contentItems[i], isDark),
            if (i < contentItems.length - 1) ...[
              Divider(color: dividerColor, height: 1),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildContentItem(PlaceContent content, bool isDark) {
    // Xác định màu chữ chung
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.key,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),

          content.isParagraph
              ? Html(data: content.value)
              : GestureDetector(
                  child: Text(
                    content.value,
                    style: AppTextStyles.body2.copyWith(
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(bool isDark, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _openGoogleMapsDirection,
          icon: const Icon(Icons.directions, size: 20),
          label: const Text('Chỉ đường'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
