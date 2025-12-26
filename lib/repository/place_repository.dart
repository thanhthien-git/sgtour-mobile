import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/models/map/map_place_model.dart';
import 'package:sgtour_mobile/models/place/place_models.dart';
import 'package:sgtour_mobile/screens/home/map/tile_math.dart';
import '../services/map_cache_service.dart';

Map<String, dynamic> parseMapDataIsolate(dynamic rawData) {
  final List rootList = rawData as List;
  if (rootList.isEmpty) return {'ttl': 300, 'places': <MapPlace>[]};

  final Map<String, dynamic> dataObj = Map<String, dynamic>.from(rootList[0]);
  final int ttl = dataObj['ttl'] ?? 300;
  final List placesRaw = dataObj['places'] ?? [];

  final places = placesRaw.map((e) {
    return MapPlace.fromJson(Map<String, dynamic>.from(e));
  }).toList();

  return {'ttl': ttl, 'places': places};
}

class MapRepository {
  static final MapRepository _instance = MapRepository._internal();
  factory MapRepository() => _instance;
  MapRepository._internal();

  final _api = ApiService();
  final _diskCache = MapCacheService.instance;

  final Map<String, List<MapPlace>> _memCache = {};
  final Set<String> _pendingKeys = {};
  bool _isFetching = false;

  Future<List<MapPlace>> fetchTiles(List<({int z, int x, int y})> tiles) async {
    if (_isFetching) return _getAllCachedPlaces();

    final List<String> missingKeys = [];
    final List<MapPlace> currentResults = [];

    for (var tile in tiles) {
      final key = '${tile.z}_${tile.x}_${tile.y}';
      if (_memCache.containsKey(key)) {
        currentResults.addAll(_memCache[key]!);
      } else {
        final diskData = _diskCache.getTile(key);
        if (diskData != null) {
          _memCache[key] = diskData;
          currentResults.addAll(diskData);
        } else if (!_pendingKeys.contains(key)) {
          missingKeys.add(key);
        }
      }
    }

    if (missingKeys.isEmpty) return _uniquePlaces(currentResults);

    _isFetching = true;
    try {
      final newPlaces = await _fetchBatchTiles(missingKeys);
      currentResults.addAll(newPlaces);
    } finally {
      _isFetching = false;
    }

    return _uniquePlaces(currentResults);
  }

  Future<List<MapPlace>> _fetchBatchTiles(List<String> keys) async {
    _pendingKeys.addAll(keys);
    try {
      final response = await _api.get(
        '/locations/map/tile',
        queryParameters: {'tiles': keys},
      );

      final parsedResult = await Isolate.run(
        () => parseMapDataIsolate(response.data),
      );

      final int ttl = parsedResult['ttl'] as int;
      final List<MapPlace> fetchedPlaces =
          parsedResult['places'] as List<MapPlace>;

      for (var k in keys) {
        _memCache[k] = [];
      }

      if (keys.isNotEmpty && fetchedPlaces.isNotEmpty) {
        final firstZoom = int.parse(keys.first.split('_')[0]);
        for (var place in fetchedPlaces) {
          final targetKey = _calculateKeyForPlace(place, firstZoom);
          if (_memCache.containsKey(targetKey)) {
            _memCache[targetKey]!.add(place);
          }
        }
      }

      for (var k in keys) {
        _diskCache.saveTile(k, _memCache[k]!, ttl);
      }

      return fetchedPlaces;
    } catch (e) {
      for (var key in keys) {
        _memCache[key] = [];
        _diskCache.saveTile(key, [], 600);
      }
      return [];
    } finally {
      _pendingKeys.removeAll(keys);
    }
  }

  String _calculateKeyForPlace(MapPlace place, int zoom) {
    final point = TileMath.project(place.lat, place.lng, zoom);
    return '${zoom}_${point.x}_${point.y}';
  }

  List<MapPlace> _getAllCachedPlaces() {
    return _uniquePlaces(_memCache.values.expand((e) => e).toList());
  }

  List<MapPlace> _uniquePlaces(List<MapPlace> places) {
    if (places.isEmpty) return [];
    final Map<String, MapPlace> uniqueMap = {};
    for (var item in places) {
      uniqueMap[item.id.toString()] = item;
    }
    return uniqueMap.values.toList();
  }

  Future<Place> getPlaceDetail(String id) async {
    final cachedPlace = _diskCache.getPlaceDetail(id);
    if (cachedPlace != null) {
      return cachedPlace;
    }
    try {
      final response = await _api.get('/locations/$id');
      _diskCache.savePlaceDetail(id, response.data).ignore();
      return Place.fromJson(response.data);
    } catch (e) {
      final stalePlace = _diskCache.getPlaceDetail(id, ignoreExpiry: true);
      if (stalePlace != null) {
        return stalePlace;
      }
      throw Exception('Không thể tải dữ liệu: $e');
    }
  }
}
