import 'dart:math';
import 'package:flutter_map/flutter_map.dart';

class TileMath {
  static Point<int> project(double lat, double lng, int zoom) {
    final n = pow(2.0, zoom);
    final latRad = lat * pi / 180.0;
    final x = ((lng + 180.0) / 360.0 * n).floor();
    final y = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n)
        .floor();
    return Point(x, y);
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
