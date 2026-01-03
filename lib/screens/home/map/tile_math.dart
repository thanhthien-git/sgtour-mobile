import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TileMath {
  static Point<int> project(double lat, double lng, int zoom) {
    final n = pow(2.0, zoom);
    final latRad = lat * pi / 180.0;
    final x = ((lng + 180.0) / 360.0 * n).floor();
    final y = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n)
        .floor();
    return Point(x, y);
  }

  static List<({int z, int x, int y})> getVisibleTilesFromLatLng(
    LatLng center,
    int currentZoom, {
    int buffer = 1,
  }) {
    if (currentZoom < 10) return [];

    // Approximate visible bounds from center (roughly 0.01 degree per zoom level)
    final offset = 0.1 / pow(2, currentZoom - 10);
    final north = center.latitude + offset;
    final south = center.latitude - offset;
    final west = center.longitude - offset;
    final east = center.longitude + offset;

    final min = project(north, west, currentZoom);
    final max = project(south, east, currentZoom);

    final minX = min.x - buffer;
    final maxX = max.x + buffer;
    final minY = min.y - buffer;
    final maxY = max.y + buffer;

    final tiles = <({int z, int x, int y})>[];
    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        final maxTile = pow(2.0, currentZoom).toInt() - 1;
        if (x >= 0 && x <= maxTile && y >= 0 && y <= maxTile) {
          tiles.add((z: currentZoom, x: x, y: y));
        }
      }
    }
    return tiles;
  }

  static List<({int z, int x, int y})> getVisibleTiles(
    MapCamera camera,
    int currentZoom, {
    int buffer = 1,
  }) {
    if (currentZoom < 10) return [];

    final bounds = camera.visibleBounds;
    final min = project(bounds.north, bounds.west, currentZoom);
    final max = project(bounds.south, bounds.east, currentZoom);

    final minX = min.x - buffer;
    final maxX = max.x + buffer;
    final minY = min.y - buffer;
    final maxY = max.y + buffer;

    final tiles = <({int z, int x, int y})>[];
    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        final maxTile = pow(2.0, currentZoom).toInt() - 1;
        if (x >= 0 && x <= maxTile && y >= 0 && y <= maxTile) {
          tiles.add((z: currentZoom, x: x, y: y));
        }
      }
    }
    return tiles;
  }
}
