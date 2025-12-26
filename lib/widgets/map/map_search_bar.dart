import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/models/map/osm_search_result.dart';
import 'package:sgtour_mobile/providers/locale_provider.dart';
import 'package:sgtour_mobile/services/osm_search_service.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class MapSearchBar extends ConsumerStatefulWidget {
  final Function(OsmSearchResult) onResultSelected;
  final VoidCallback? onAiTap;
  const MapSearchBar({super.key, required this.onResultSelected, this.onAiTap});

  @override
  ConsumerState<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends ConsumerState<MapSearchBar> {
  final _controller = TextEditingController();
  final _service = OsmSearchService();

  List<OsmSearchResult> _results = [];
  Timer? _debounce;
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isLoading = true);

    final localeCode = ref.read(localeProvider).locale.languageCode;
    final places = await _service.searchPlaces(query, localeCode);

    if (mounted) {
      setState(() {
        _results = places;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() => _results = []);
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.only(left: 16, right: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => _performSearch(value),
            textAlignVertical: TextAlignVertical.center,
            style: AppTextStyles.body1.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.map_search_hint,
              hintStyle: AppTextStyles.body1.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiary,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,

              // Prefix Icon
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              prefixIcon: Icon(
                Icons.search,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: 24,
              ),

              filled: false,
              fillColor: Colors.transparent,

              suffixIconConstraints: const BoxConstraints(minHeight: 40),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_controller.text.isNotEmpty)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: _clearSearch,
                    ),
                ],
              ),
            ),
          ),
        ),

        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _results.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              itemBuilder: (context, index) {
                final place = _results[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  title: Text(
                    place.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    widget.onResultSelected(place);
                    _clearSearch();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
