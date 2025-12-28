import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sgtour_mobile/services/storage_service.dart';

const String _qrCacheKeyPrefix = 'qr_detection_cache_';

class QrDetectionCacheManager {
  static final QrDetectionCacheManager _instance =
      QrDetectionCacheManager._internal();

  final Map<String, CachedQrResult> _memoryCache = {};

  static const Duration _cacheDuration = Duration(hours: 24);

  QrDetectionCacheManager._internal();

  static QrDetectionCacheManager get instance => _instance;

  CachedQrResult? getCachedResult(String qrValue) {
    if (_memoryCache.containsKey(qrValue)) {
      final cached = _memoryCache[qrValue]!;
      if (!cached.isExpired) {
        return cached;
      } else {
        _memoryCache.remove(qrValue);
      }
    }
    try {
      final jsonStr = StorageService.instance.getString(
        _qrCacheKeyPrefix + qrValue,
      );
      if (jsonStr != null) {
        final result = CachedQrResult.fromJson(jsonStr);
        if (!result.isExpired) {
          _memoryCache[qrValue] = result;
          return result;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<void> cacheResult(
    String qrValue,
    dynamic resultData, {
    required String resultType,
  }) async {
    try {
      final result = CachedQrResult(
        qrValue: qrValue,
        resultData: resultData,
        resultType: resultType,
        cachedAt: DateTime.now(),
      );

      // Update memory cache
      _memoryCache[qrValue] = result;

      // Store in persistent cache
      await StorageService.instance.setString(
        _qrCacheKeyPrefix + qrValue,
        result.toJson(),
      );
    } catch (e) {
      if (kDebugMode) print('Cache error: $e');
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      // Remove expired from memory
      _memoryCache.removeWhere((_, value) => value.isExpired);

      // In real app, you'd iterate persistent cache too
      // For now, we rely on lazy removal
    } catch (_) {}
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    // In real implementation, clear persistent storage too
  }
}

/// Cached QR Detection Result
class CachedQrResult {
  final String qrValue;
  final dynamic resultData;
  final String resultType; // 'location_id', 'url', 'text'
  final DateTime cachedAt;

  CachedQrResult({
    required this.qrValue,
    required this.resultData,
    required this.resultType,
    required this.cachedAt,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt) >
      QrDetectionCacheManager._cacheDuration;

  String toJson() => '$qrValue|$resultType|${cachedAt.millisecondsSinceEpoch}';

  factory CachedQrResult.fromJson(String json) {
    final parts = json.split('|');
    return CachedQrResult(
      qrValue: parts[0],
      resultData: parts[0],
      resultType: parts[1],
      cachedAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2])),
    );
  }
}
