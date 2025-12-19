import 'dart:isolate';
import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';
import '../services/map_cache_service.dart';
import '../../../../models/place/place_models.dart';

class MapRepository {
  static final MapRepository _instance = MapRepository._internal();
  factory MapRepository() => _instance;
  MapRepository._internal();

  final _api = ApiService();
  final _diskCache = MapCacheService.instance;
  final Map<String, List<MapPlace>> _memCache = {};

  Future<List<MapPlace>> fetchTiles(List<({int z, int x, int y})> tiles) async {
    final List<MapPlace> result = [];
    final List<({int z, int x, int y})> missingTiles = [];
    for (var tile in tiles) {
      final key = '${tile.z}_${tile.x}_${tile.y}';
      if (_memCache.containsKey(key)) {
        result.addAll(_memCache[key]!);
        continue;
      }
      final diskData = _diskCache.getTile(key);
      if (diskData != null) {
        _memCache[key] = diskData;
        result.addAll(diskData);
        continue;
      }
      missingTiles.add(tile);
    }
    if (missingTiles.isNotEmpty) {
      for (var tile in missingTiles) {
        try {
          final key = '${tile.z}_${tile.x}_${tile.y}';
          final response = await _api.get(
            '/locations/map/tile',
            queryParameters: {'z': tile.z, 'x': tile.x, 'y': tile.y},
          );
          final parsedData = await Isolate.run(() {
            final List rootList = response.data as List;
            if (rootList.isEmpty) return (ttl: 300, places: <MapPlace>[]);
            final Map<String, dynamic> dataObj = rootList[0];
            final int ttl = dataObj['ttl'] ?? 300;
            final List placesRaw = dataObj['places'] ?? [];
            final places = placesRaw.map((e) => MapPlace.fromJson(e)).toList();
            return (ttl: ttl, places: places);
          });
          _memCache[key] = parsedData.places;
          _diskCache.saveTile(key, parsedData.places, parsedData.ttl);

          if (parsedData.places.isNotEmpty) {
            result.addAll(parsedData.places);
          }
        } catch (e) {
          // Log error
        }
      }
    }
    final uniqueMap = {for (var item in result) item.id: item};
    return uniqueMap.values.toList();
  }

  Future<Place> getPlaceDetail(String id) async {
    try {
      final response = await _api.get('/locations/$id');

      return Place.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải thông tin địa điểm: $e');
    }
  }
}
