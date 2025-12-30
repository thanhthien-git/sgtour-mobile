import 'package:hive_flutter/adapters.dart';
import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/services/file/config_service.dart';
import 'package:sgtour_mobile/services/map/cache/tile_cache_manager.dart';
import 'package:sgtour_mobile/services/file/storage_service.dart';

class BootstrapService {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await StorageService.initialize();
    await ConfigService.initialize();
    await ApiService.initialize();
    await TileCacheManager.instance.init();
  }
}
