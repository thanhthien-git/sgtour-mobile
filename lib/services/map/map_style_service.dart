import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sgtour_mobile/services/file/config_service.dart';

class MapStyleService {
  static final MapStyleService instance = MapStyleService._();
  MapStyleService._();

  String? _cachedStyleJson;

  static const Duration _styleCacheDuration = Duration(days: 7);

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<String> getStyleString() async {
    if (_cachedStyleJson != null) {
      return _cachedStyleJson!;
    }

    final cachedStyle = await _loadCachedStyle();
    if (cachedStyle != null) {
      _cachedStyleJson = cachedStyle;
      return cachedStyle;
    }

    final modifiedStyle = await _fetchAndModifyStyle();
    _cachedStyleJson = modifiedStyle;

    await _saveStyleToCache(modifiedStyle);

    return modifiedStyle;
  }

  Future<String> _fetchAndModifyStyle() async {
    try {
      final baseUrl = ConfigService.instance.apiBaseUrl;
      final styleUrl = '$baseUrl/tiles/style';

      debugPrint(
        '📍 Fetching map style from: $styleUrl on ${Platform.isIOS ? 'iOS' : 'Android'}',
      );

      final response = await _dio.get(styleUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> style;

        if (response.data is String) {
          style = jsonDecode(response.data);
        } else {
          style = Map<String, dynamic>.from(response.data);
        }

        debugPrint(
          '✓ Style fetched. Layers: ${(style['layers'] as List?)?.length ?? 0}',
        );

        final backendTileUrl = '$baseUrl/tiles/{z}/{x}/{y}';

        if (style['sources'] != null) {
          final sources = style['sources'] as Map<String, dynamic>;

          for (final key in sources.keys) {
            final source = sources[key];
            if (source is Map && source['type'] == 'vector') {
              source['tiles'] = [backendTileUrl];
              source.remove('url');
            }
          }
        }

        return jsonEncode(style);
      } else {
        debugPrint('❌ Failed to fetch style: ${response.statusCode}');
        throw Exception('Failed to fetch style: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _fetchAndModifyStyle: $e\n$stackTrace');
      rethrow;
      // return _getFallbackStyle();
    }
  }

  Future<String?> _loadCachedStyle() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final styleFile = File('${dir.path}/vietmap_style_modified.json');

      if (await styleFile.exists()) {
        final lastModified = await styleFile.lastModified();
        final age = DateTime.now().difference(lastModified);

        if (age < _styleCacheDuration) {
          return await styleFile.readAsString();
        } else {
          await styleFile.delete();
        }
      }
    } catch (e) {}
    return null;
  }

  Future<void> _saveStyleToCache(String styleJson) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final styleFile = File('${dir.path}/vietmap_style_modified.json');
      await styleFile.writeAsString(styleJson);
    } catch (e) {
      debugPrint('Failed to save style to cache: $e');
    }
  }

  Future<void> invalidateStyle() async {
    _cachedStyleJson = null;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final styleFile = File('${dir.path}/vietmap_style_modified.json');
      if (await styleFile.exists()) {
        await styleFile.delete();
      }
    } catch (e) {}
  }

  Future<String> forceRefresh() async {
    await invalidateStyle();
    return await getStyleString();
  }

  // String _getFallbackStyle() {
  //   final baseUrl = ConfigService.instance.apiBaseUrl;
  //   final tileUrl = '$baseUrl/tiles/{z}/{x}/{y}';

  //   final style = {
  //     'version': 8,
  //     'name': 'SGTour Fallback',
  //     'glyphs': 'https://fonts.openmaptiles.org/{fontstack}/{range}.pbf',
  //     'sources': {
  //       'vietmap': {
  //         'type': 'vector',
  //         'tiles': [tileUrl],
  //         'minzoom': 0,
  //         'maxzoom': 15,
  //       },
  //     },
  //     'layers': [
  //       // Background layer
  //       {
  //         'id': 'background',
  //         'type': 'background',
  //         'paint': {'background-color': '#f0f0f0'},
  //       },
  //       // Water layer
  //       {
  //         'id': 'water',
  //         'type': 'fill',
  //         'source': 'vietmap',
  //         'source-layer': 'water',
  //         'paint': {'fill-color': '#a0d3ff', 'fill-opacity': 1.0},
  //       },
  //       // Landuse layer
  //       {
  //         'id': 'landuse',
  //         'type': 'fill',
  //         'source': 'vietmap',
  //         'source-layer': 'landuse',
  //         'paint': {'fill-color': '#e8e8e8', 'fill-opacity': 0.5},
  //       },
  //       // Building layer
  //       {
  //         'id': 'building',
  //         'type': 'fill',
  //         'source': 'vietmap',
  //         'source-layer': 'building',
  //         'paint': {'fill-color': '#d4d4d4', 'fill-opacity': 0.6},
  //       },
  //       // Main roads/highways
  //       {
  //         'id': 'road-highway',
  //         'type': 'line',
  //         'source': 'vietmap',
  //         'source-layer': 'road',
  //         'filter': [
  //           'match',
  //           ['get', 'class'],
  //           ['motorway', 'trunk', 'primary'],
  //           true,
  //           false,
  //         ],
  //         'paint': {
  //           'line-color': '#ffc566',
  //           'line-width': [
  //             'interpolate',
  //             ['linear'],
  //             ['zoom'],
  //             6,
  //             1,
  //             14,
  //             4,
  //           ],
  //         },
  //         'layout': {'line-join': 'round', 'line-cap': 'round'},
  //       },
  //       // Secondary roads
  //       {
  //         'id': 'road-secondary',
  //         'type': 'line',
  //         'source': 'vietmap',
  //         'source-layer': 'road',
  //         'filter': [
  //           'match',
  //           ['get', 'class'],
  //           ['secondary', 'tertiary'],
  //           true,
  //           false,
  //         ],
  //         'paint': {
  //           'line-color': '#ffed99',
  //           'line-width': [
  //             'interpolate',
  //             ['linear'],
  //             ['zoom'],
  //             6,
  //             0.5,
  //             14,
  //             2,
  //           ],
  //         },
  //         'layout': {'line-join': 'round', 'line-cap': 'round'},
  //       },
  //       // Streets/local roads
  //       {
  //         'id': 'road-street',
  //         'type': 'line',
  //         'source': 'vietmap',
  //         'source-layer': 'road',
  //         'filter': [
  //           'match',
  //           ['get', 'class'],
  //           ['residential', 'unclassified', 'service', 'footway', 'track'],
  //           true,
  //           false,
  //         ],
  //         'paint': {
  //           'line-color': '#ffffff',
  //           'line-width': [
  //             'interpolate',
  //             ['linear'],
  //             ['zoom'],
  //             10,
  //             0.3,
  //             14,
  //             1.5,
  //           ],
  //         },
  //         'layout': {'line-join': 'round', 'line-cap': 'round'},
  //       },
  //       // Fallback for all roads
  //       {
  //         'id': 'road-other',
  //         'type': 'line',
  //         'source': 'vietmap',
  //         'source-layer': 'road',
  //         'paint': {
  //           'line-color': '#ffffff',
  //           'line-width': [
  //             'interpolate',
  //             ['linear'],
  //             ['zoom'],
  //             6,
  //             0.1,
  //             14,
  //             1,
  //           ],
  //         },
  //         'layout': {'line-join': 'round', 'line-cap': 'round'},
  //       },
  //       // POI layer (if available)
  //       {
  //         'id': 'poi',
  //         'type': 'circle',
  //         'source': 'vietmap',
  //         'source-layer': 'poi',
  //         'paint': {
  //           'circle-radius': [
  //             'interpolate',
  //             ['linear'],
  //             ['zoom'],
  //             12,
  //             2,
  //             15,
  //             6,
  //           ],
  //           'circle-color': '#ff6b6b',
  //           'circle-opacity': 0.7,
  //         },
  //       },
  //     ],
  //   };

  //   return jsonEncode(style);
  // }
}
