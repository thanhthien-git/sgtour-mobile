import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:sgtour_mobile/models/map/search_place_model.dart';
import 'package:sgtour_mobile/repository/place_repository.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';

class PlacesSearchBar extends StatefulWidget {
  final Function(LatLng location, String placeName) onPlaceSelected;
  final String? hintText;

  const PlacesSearchBar({
    super.key,
    required this.onPlaceSelected,
    this.hintText,
  });

  @override
  State<PlacesSearchBar> createState() => _PlacesSearchBarState();
}

class _PlacesSearchBarState extends State<PlacesSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final MapRepository _repository = MapRepository();
  final LayerLink _layerLink = LayerLink();

  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;
  List<SearchPlaceResult> _searchResults = [];
  bool _isSearching = false;
  bool _hasError = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _searchResults.isNotEmpty) {
      _showOverlay();
    } else if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
        _hasError = false;
      });
      _removeOverlay();
      return;
    }

    setState(() {
      _isSearching = true;
      _hasError = false;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final response = await _repository.searchPlaces(keyword: query, limit: 5);

      if (!mounted) return;

      setState(() {
        _searchResults = response.data;
        _isSearching = false;
        _showResults = true;
        _hasError = false;
      });

      if (_searchResults.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isSearching = false;
        _hasError = true;
        _showResults = false;
      });
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: _buildResultsList(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onPlaceSelected(SearchPlaceResult place) {
    _controller.text = place.title;
    _focusNode.unfocus();
    _removeOverlay();

    setState(() {
      _searchResults = [];
      _showResults = false;
    });

    widget.onPlaceSelected(
      LatLng(place.latitude, place.longitude),
      place.title,
    );
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _searchResults = [];
      _showResults = false;
      _hasError = false;
    });
    _removeOverlay();
  }

  Widget _buildResultsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? Colors.grey[800] : Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final place = _searchResults[index];
          return _buildResultItem(place, isDark);
        },
      ),
    );
  }

  Widget _buildResultItem(SearchPlaceResult place, bool isDark) {
    return InkWell(
      onTap: () => _onPlaceSelected(place),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (place.address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      place.address,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: AppTextStyles.subtitle2.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? context.l10n.map_search_hint,
            hintStyle: AppTextStyles.subtitle2.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: _isSearching
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.clear,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    onPressed: _isSearching ? null : _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            fillColor: Colors.transparent,
            focusColor: Colors.transparent,
            focusedErrorBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
