import 'package:hive_flutter/adapters.dart';
import 'package:sgtourcus/api/api_service.dart';
import 'package:sgtourcus/services/file/config_service.dart';
import 'package:sgtourcus/services/file/storage_service.dart';
import 'package:sgtourcus/services/map/cache/tile_cache_manager.dart';

class BootstrapService {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await StorageService.initialize();
    await ConfigService.initialize();
    await ApiService.initialize();
    await TileCacheManager.instance.init();
  }
}
