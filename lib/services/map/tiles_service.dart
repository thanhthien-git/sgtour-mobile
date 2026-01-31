import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sgtourcus/services/file/config_service.dart';
import 'package:sgtourcus/services/map/cache/tile_cache_manager.dart';

class TilesService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.bytes,
    ),
  );

  static Future<File> getTile(String z, String x, String y) async {
    final cachedFile = await TileCacheManager.instance.getValidCacheFile(
      z,
      x,
      y,
    );
    if (cachedFile != null) {
      return cachedFile;
    }

    try {
      final url = '${ConfigService.instance.apiBaseUrl}/tiles/$z/$x/$y';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return await TileCacheManager.instance.saveCacheFile(
          z,
          x,
          y,
          response.data,
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Map Service Error ($z/$x/$y): $e");
      throw e;
    }
  }
}
