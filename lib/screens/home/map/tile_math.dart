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
    int currentZoom,
  ) {
    if (currentZoom < 10) return [];

    final bounds = camera.visibleBounds;
    final min = project(bounds.north, bounds.west, currentZoom);
    final max = project(bounds.south, bounds.east, currentZoom);

    final tiles = <({int z, int x, int y})>[];
    for (var x = min.x; x <= max.x; x++) {
      for (var y = min.y; y <= max.y; y++) {
        tiles.add((z: currentZoom, x: x, y: y));
      }
    }
    return tiles;
  }
}
