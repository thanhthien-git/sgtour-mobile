import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../models/place/place_models.dart';
import '../../enums/enums.dart';
import '../../providers/locale_provider.dart';
import 'place_image_gallery.dart';
import 'place_language_switcher.dart';

class PlaceDetailSheet extends ConsumerStatefulWidget {
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
  ConsumerState<PlaceDetailSheet> createState() => _PlaceDetailSheetState();
}

class _PlaceDetailSheetState extends ConsumerState<PlaceDetailSheet> {
  late PlaceLanguage _selectedLanguage;
  late PlaceTranslation? _currentTranslation;
  final Set<String> _expandedItems = {};
  final _scrollController = DraggableScrollableController();
  double _maxChildSize = 0.7;

  @override
  void initState() {
    super.initState();

    // Lấy ngôn ngữ hiện tại của user
    final currentLocale = ref.read(localeProvider).locale;
    final userLanguageCode = currentLocale.languageCode;

    // Tìm PlaceLanguage tương ứng
    PlaceLanguage? userLanguage;
    try {
      userLanguage = PlaceLanguage.fromCode(userLanguageCode);
    } catch (e) {
      userLanguage = null;
    }

    // Kiểm tra xem place có bản dịch ngôn ngữ user không
    if (userLanguage != null &&
        widget.place.availableLanguages.contains(userLanguage)) {
      _selectedLanguage = userLanguage;
    } else {
      // Fallback về tiếng Việt nếu có, không thì dùng default
      if (widget.place.availableLanguages.contains(PlaceLanguage.vi)) {
        _selectedLanguage = PlaceLanguage.vi;
      } else {
        _selectedLanguage = widget.place.defaultLanguage;
      }
    }

    _currentTranslation = widget.place.getTranslation(_selectedLanguage);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onLanguageChanged(PlaceLanguage language) {
    setState(() {
      _selectedLanguage = language;
      _currentTranslation = widget.place.getTranslation(language);
      _expandedItems.clear();
    });
  }

  void _toggleExpanded(String contentKey) {
    setState(() {
      if (_expandedItems.contains(contentKey)) {
        _expandedItems.remove(contentKey);
        _maxChildSize = 0.7;
      } else {
        _expandedItems.add(contentKey);
        _maxChildSize = 0.95;
      }
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
      controller: _scrollController,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: _maxChildSize,
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
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
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

                    SliverToBoxAdapter(child: _buildHeader(isDark)),

                    SliverToBoxAdapter(child: _buildDynamicContent(isDark)),
                  ],
                ),
              ),

              _buildDirectionButton(isDark, bottomPadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    final translation = _currentTranslation;
    final title = translation?.title ?? widget.place.metadata.title;
    final address = translation?.address ?? widget.place.metadata.address;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.heading5.copyWith(
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
                  style: AppTextStyles.subtitle2.copyWith(
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

    final highlightedItems = contentItems
        .where((c) => c.isHighlight ?? false)
        .toList();
    final nonHighlightedItems = contentItems
        .where((c) => !(c.isHighlight ?? false))
        .toList();

    final dividerColor = isDark ? Colors.grey[800] : Colors.grey[200];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < highlightedItems.length; i++) ...[
            _buildContentItem(highlightedItems[i], isDark),
            if (i < highlightedItems.length - 1 ||
                nonHighlightedItems.isNotEmpty) ...[
              Divider(color: dividerColor, height: 1),
            ],
          ],

          if (nonHighlightedItems.isNotEmpty) ...[
            _buildReadMoreSection(nonHighlightedItems, isDark, dividerColor),
          ],
        ],
      ),
    );
  }

  Widget _buildReadMoreSection(
    List<PlaceContent> items,
    bool isDark,
    Color? dividerColor,
  ) {
    final isExpanded = _expandedItems.contains('__readmore_section__');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: dividerColor, height: 1),

        _buildExpandButton(isDark, isExpanded),

        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topLeft,
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _buildContentItem(items[i], isDark),
                        if (i < items.length - 1)
                          Divider(color: dividerColor, height: 1),
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandButton(bool isDark, bool isExpanded) {
    return InkWell(
      onTap: () => _toggleExpanded('__readmore_section__'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isExpanded
                    ? context.l10n.place_readLess
                    : context.l10n.place_readMore,
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentItem(PlaceContent content, bool isDark) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    final baseTextStyle = AppTextStyles.subtitle2.copyWith(color: textColor);

    final htmlStyle = {
      "body": Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        color: textColor,
        fontSize: FontSize(baseTextStyle.fontSize ?? 14),
        fontWeight: baseTextStyle.fontWeight,
        fontFamily: baseTextStyle.fontFamily,
        lineHeight: LineHeight(1.4),
        textAlign: TextAlign.left,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content.key,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          content.isParagraph
              ? Html(data: content.value, style: htmlStyle)
              : Text(content.value, style: baseTextStyle),
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
