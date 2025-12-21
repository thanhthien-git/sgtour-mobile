import 'package:hive_flutter/hive_flutter.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';

class MapCacheService {
  static const _boxName = 'map_tile_cache_v1';

  static final MapCacheService instance = MapCacheService._();
  MapCacheService._();

  Box? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  List<MapPlace>? getTile(String key) {
    if (_box == null) return null;
    final data = _box!.get(key);
    if (data == null) return null;

    final int expiry = data['expiry'] ?? 0;
    final int now = DateTime.now().millisecondsSinceEpoch;

    if (now > expiry) {
      _box!.delete(key);
      return null;
    }

    final itemsRaw = data['items'] as List;
    // Cast an toàn
    return itemsRaw
        .map((e) => MapPlace.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveTile(
    String key,
    List<MapPlace> places,
    int ttlSeconds,
  ) async {
    if (_box == null) return;

    final expiry = DateTime.now().millisecondsSinceEpoch + (ttlSeconds * 1000);
    final itemsJson = places.map((e) => e.toJson()).toList();

    _box!.put(key, {'expiry': expiry, 'items': itemsJson});
  }
}
