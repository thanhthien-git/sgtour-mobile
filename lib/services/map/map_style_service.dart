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

      final response = await _dio.get(styleUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> style;

        if (response.data is String) {
          style = jsonDecode(response.data);
        } else {
          style = Map<String, dynamic>.from(response.data);
        }

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
        throw Exception('Failed to fetch style: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      return _getFallbackStyle();
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

  // Force a fresh fetch from the API (ignore cache)
  Future<String> forceRefresh() async {
    await invalidateStyle();
    return await getStyleString();
  }

  String _getFallbackStyle() {
    final baseUrl = ConfigService.instance.apiBaseUrl;
    final tileUrl = '$baseUrl/tiles/{z}/{x}/{y}';

    final style = {
      'version': 8,
      'name': 'SGTour Fallback',
      'sources': {
        'vietmap': {
          'type': 'vector',
          'tiles': [tileUrl],
          'minzoom': 0,
          'maxzoom': 20,
        },
      },
      'layers': [
        {
          'id': 'background',
          'type': 'background',
          'paint': {'background-color': '#f0f0f0'},
        },
      ],
    };

    return jsonEncode(style);
  }
}
