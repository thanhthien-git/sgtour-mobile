import 'package:sgtour_mobile/services/config_service.dart';
import 'package:sgtour_mobile/services/storage_service.dart';

import '../api/api_service.dart';

abstract class AppBootstrap {
  static Future<void> initialize() async {
    await StorageService.initialize();
    await ConfigService.initialize();
    await ApiService.initialize();
  }
}

class BootstrapService implements AppBootstrap {
  static Future<void> initialize() => AppBootstrap.initialize();
}
