import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';
import 'package:sgtour_mobile/models/models.dart';

class MapCacheService {
  static const _tileBoxName = 'map_tile_cache_v1';
  static const _detailBoxName = 'place_detail_cache_v1';

  static final MapCacheService instance = MapCacheService._();
  MapCacheService._();

  Box? _tileBox;
  Box? _detailBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_tileBoxName)) {
      _tileBox = await Hive.openBox(_tileBoxName);
    } else {
      _tileBox = Hive.box(_tileBoxName);
    }

    if (!Hive.isBoxOpen(_detailBoxName)) {
      _detailBox = await Hive.openBox(_detailBoxName);
    } else {
      _detailBox = Hive.box(_detailBoxName);
    }
  }

  List<MapPlace>? getTile(String key) {
    if (_tileBox == null) return null;

    final data = _tileBox!.get(key);
    if (data == null) {
      debugPrint("⚠️ CACHE MISS (Tile): $key -> Sẽ gọi API");
      return null;
    }

    final int expiry = data['expiry'] ?? 0;
    final int now = DateTime.now().millisecondsSinceEpoch;

    if (now > expiry) {
      debugPrint("⏰ CACHE EXPIRED (Tile): $key -> Xóa cache cũ");
      _tileBox!.delete(key);
      return null;
    }

    debugPrint("✅ CACHE HIT (Tile): $key -> Lấy từ Local Hive");
    final itemsRaw = data['items'] as List;
    return itemsRaw
        .map((e) => MapPlace.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveTile(
    String key,
    List<MapPlace> places,
    int ttlSeconds,
  ) async {
    if (_tileBox == null) return;
    debugPrint("💾 SAVING CACHE (Tile): $key -> Lưu ${places.length} địa điểm");

    final expiry = DateTime.now().millisecondsSinceEpoch + (ttlSeconds * 1000);
    final itemsJson = places.map((e) => e.toJson()).toList();

    await _tileBox!.put(key, {'expiry': expiry, 'items': itemsJson});
  }

  Place? getPlaceDetail(String id, {bool ignoreExpiry = false}) {
    if (_detailBox == null) return null;

    final entry = _detailBox!.get(id);
    if (entry == null) return null;

    final wrapper = Map<String, dynamic>.from(entry);
    final int timestamp = wrapper['timestamp'] ?? 0;

    const ttlMillis = 30 * 60 * 1000;
    final isExpired =
        (DateTime.now().millisecondsSinceEpoch - timestamp) > ttlMillis;

    if (isExpired && !ignoreExpiry) {
      return null;
    }

    try {
      final realData = Map<String, dynamic>.from(wrapper['data']);
      return Place.fromJson(realData);
    } catch (e) {
      print("Cache parse error: $e");
      return null;
    }
  }

  Future<void> savePlaceDetail(String id, Map<String, dynamic> data) async {
    if (_detailBox == null) return;

    await _detailBox!.put(id, {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    });
  }
}
