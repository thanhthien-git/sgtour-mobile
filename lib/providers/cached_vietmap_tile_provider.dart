import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sgtour_mobile/services/map/map_service.dart';
import 'package:sgtour_mobile/services/map/tiles_service.dart';

class CachedVietmapTileProvider extends TileProvider {
  CachedVietmapTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    // Chỉ cần truyền toạ độ, không cần URL template vì Service tự lo
    return _VietmapCachedImageProvider(
      coordinates.z.toString(),
      coordinates.x.toString(),
      coordinates.y.toString(),
    );
  }
}

class _VietmapCachedImageProvider
    extends ImageProvider<_VietmapCachedImageProvider> {
  final String z;
  final String x;
  final String y;

  _VietmapCachedImageProvider(this.z, this.x, this.y);

  @override
  Future<_VietmapCachedImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _VietmapCachedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: '$z/$x/$y',
      informationCollector: () => [DiagnosticsProperty('Tile', '$z/$x/$y')],
    );
  }

  Future<ui.Codec> _loadAsync(
    _VietmapCachedImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    try {
      final File file = await TilesService.getTile(z, x, y);

      final bytes = await file.readAsBytes();
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      return _loadTransparentImage(decode);
    }
  }

  Future<ui.Codec> _loadTransparentImage(ImageDecoderCallback decode) async {
    final Uint8List transparent = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ]);
    final buffer = await ui.ImmutableBuffer.fromUint8List(transparent);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _VietmapCachedImageProvider &&
        other.z == z &&
        other.x == x &&
        other.y == y;
  }

  @override
  int get hashCode => Object.hash(z, x, y);
}
