import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TileCacheManager {
  static final TileCacheManager instance = TileCacheManager._();
  TileCacheManager._();

  String? _cachePath;
  static const Duration _cacheDuration = Duration(days: 7);

  Future<void> init() async {
    if (_cachePath != null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/vietmap_tiles');
      if (!cacheDir.existsSync()) {
        cacheDir.createSync(recursive: true);
      }
      _cachePath = cacheDir.path;
    } catch (e) {}
  }

  Future<File?> getValidCacheFile(String z, String x, String y) async {
    await init();
    if (_cachePath == null) return null;

    final fileName = '${z}_${x}_$y.png';
    final file = File('$_cachePath/$fileName');

    if (file.existsSync()) {
      final lastModified = file.lastModifiedSync();
      if (DateTime.now().difference(lastModified) < _cacheDuration) {
        return file;
      } else {
        file.deleteSync();
      }
    }
    return null;
  }

  Future<File> saveCacheFile(
    String z,
    String x,
    String y,
    List<int> bytes,
  ) async {
    await init();
    final fileName = '${z}_${x}_$y.png';
    final file = File('$_cachePath/$fileName');
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<void> clearCache() async {
    if (_cachePath == null) return;
    final dir = Directory(_cachePath!);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
      _cachePath = null;
    }
  }
}
