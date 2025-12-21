import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';
import 'package:sgtour_mobile/models/place/place_models.dart';
import '../services/map_cache_service.dart';

class MapRepository {
  static final MapRepository _instance = MapRepository._internal();
  factory MapRepository() => _instance;
  MapRepository._internal();

  final _api = ApiService();
  final _diskCache = MapCacheService.instance;

  final Map<String, List<MapPlace>> _memCache = {};

  final Set<String> _pendingKeys = {};

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

      if (!_pendingKeys.contains(key)) {
        missingTiles.add(tile);
      }
    }

    if (missingTiles.isEmpty) {
      return _uniquePlaces(result);
    }

    await Future.wait(
      missingTiles.map((tile) => _fetchSingleTile(tile, result)),
    );

    return _uniquePlaces(result);
  }

  Future<void> _fetchSingleTile(
    ({int z, int x, int y}) tile,
    List<MapPlace> resultCollector,
  ) async {
    final key = '${tile.z}_${tile.x}_${tile.y}';
    _pendingKeys.add(key);

    try {
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

      resultCollector.addAll(parsedData.places);
    } catch (e) {
      debugPrint("Error fetching tile $key: $e");
    } finally {
      _pendingKeys.remove(key);
    }
  }

  List<MapPlace> _uniquePlaces(List<MapPlace> places) {
    final uniqueMap = {for (var item in places) item.id: item};
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
