import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class PbfTileCacheManager {
  static final PbfTileCacheManager instance = PbfTileCacheManager._();
  PbfTileCacheManager._();

  static const Duration _cacheDuration = Duration(days: 7);
  static const String _dbName = 'vietmap_tile_cache.db';
  static const String _tileFolderName = 'vietmap_pbf_tiles';
  static const int _maxCacheSize = 500 * 1024 * 1024;

  Database? _db;
  String? _tileCachePath;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final docDir = await getApplicationDocumentsDirectory();

      final tileDir = Directory('${docDir.path}/$_tileFolderName');
      if (!tileDir.existsSync()) {
        await tileDir.create(recursive: true);
      }
      _tileCachePath = tileDir.path;

      final dbPath = path.join(docDir.path, _dbName);
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS tiles (
              key TEXT PRIMARY KEY,
              file_path TEXT NOT NULL,
              size INTEGER NOT NULL,
              created_at INTEGER NOT NULL,
              last_accessed INTEGER NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_created_at ON tiles(created_at)',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_last_accessed ON tiles(last_accessed)',
          );
        },
      );

      _initialized = true;

      _cleanupExpiredTiles();
    } catch (e) {}
  }

  Future<Uint8List?> getCachedTile(int z, int x, int y) async {
    if (!_initialized || _db == null) return null;

    final key = _getTileKey(z, x, y);

    try {
      final result = await _db!.query(
        'tiles',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (result.isEmpty) return null;

      final row = result.first;
      final createdAt = DateTime.fromMillisecondsSinceEpoch(
        row['created_at'] as int,
      );

      if (DateTime.now().difference(createdAt) > _cacheDuration) {
        _deleteTile(key, row['file_path'] as String);
        return null;
      }

      final file = File(row['file_path'] as String);
      if (!file.existsSync()) {
        await _db!.delete('tiles', where: 'key = ?', whereArgs: [key]);
        return null;
      }

      await _db!.update(
        'tiles',
        {'last_accessed': DateTime.now().millisecondsSinceEpoch},
        where: 'key = ?',
        whereArgs: [key],
      );

      return await file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveTile(int z, int x, int y, Uint8List data) async {
    if (!_initialized || _db == null || _tileCachePath == null) return;

    final key = _getTileKey(z, x, y);
    final filePath = '$_tileCachePath/$key.pbf';
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      final file = File(filePath);
      await file.writeAsBytes(data, flush: true);

      await _db!.insert('tiles', {
        'key': key,
        'file_path': filePath,
        'size': data.length,
        'created_at': now,
        'last_accessed': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      _checkCacheSizeIfNeeded();
    } catch (e) {}
  }

  Future<bool> hasTile(int z, int x, int y) async {
    if (!_initialized || _db == null) return false;

    final key = _getTileKey(z, x, y);

    try {
      final result = await _db!.query(
        'tiles',
        columns: ['key'],
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<int> getCacheSize() async {
    if (!_initialized || _db == null) return 0;

    try {
      final result = await _db!.rawQuery(
        'SELECT SUM(size) as total FROM tiles',
      );
      return (result.first['total'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getCachedTileCount() async {
    if (!_initialized || _db == null) return 0;

    try {
      final result = await _db!.rawQuery('SELECT COUNT(*) as count FROM tiles');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearCache() async {
    if (!_initialized) return;

    try {
      if (_tileCachePath != null) {
        final dir = Directory(_tileCachePath!);
        if (dir.existsSync()) {
          await dir.delete(recursive: true);
          await dir.create(recursive: true);
        }
      }

      if (_db != null) {
        await _db!.delete('tiles');
      }
    } catch (e) {}
  }

  String _getTileKey(int z, int x, int y) => '${z}_${x}_$y';

  Future<void> _deleteTile(String key, String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
      await _db!.delete('tiles', where: 'key = ?', whereArgs: [key]);
    } catch (e) {}
  }

  void _cleanupExpiredTiles() {
    if (!_initialized || _db == null) return;

    Future.microtask(() async {
      try {
        final expireTime = DateTime.now()
            .subtract(_cacheDuration)
            .millisecondsSinceEpoch;

        final expired = await _db!.query(
          'tiles',
          where: 'created_at < ?',
          whereArgs: [expireTime],
        );

        for (final row in expired) {
          await _deleteTile(row['key'] as String, row['file_path'] as String);
        }

        if (expired.isNotEmpty) {
          debugPrint('🗑️ Cleaned up ${expired.length} expired tiles');
        }
      } catch (e) {}
    });
  }

  int _checkCounter = 0;
  void _checkCacheSizeIfNeeded() {
    _checkCounter++;
    if (_checkCounter % 100 != 0) return;

    Future.microtask(() async {
      try {
        final size = await getCacheSize();
        if (size > _maxCacheSize) {
          await _evictOldTiles(size - (_maxCacheSize ~/ 2));
        }
      } catch (e) {}
    });
  }

  Future<void> _evictOldTiles(int bytesToFree) async {
    if (!_initialized || _db == null) return;

    try {
      int freedBytes = 0;

      final oldTiles = await _db!.query(
        'tiles',
        orderBy: 'last_accessed ASC',
        limit: 1000,
      );

      for (final row in oldTiles) {
        if (freedBytes >= bytesToFree) break;

        await _deleteTile(row['key'] as String, row['file_path'] as String);
        freedBytes += row['size'] as int;
      }
    } catch (e) {}
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
    _initialized = false;
  }
}
