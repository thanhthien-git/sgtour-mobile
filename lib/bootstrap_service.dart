// bootstrap_service.dart
import 'dart:developer';

import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/services/config_service.dart';
import 'package:sgtour_mobile/services/storage_service.dart';

class BootstrapService {
  static Future<void> initialize() async {
    final stopwatch = Stopwatch()..start();

    log('--- START BOOTSTRAP ---');

    // 1. Đo Storage
    final startStorage = stopwatch.elapsedMilliseconds;
    await StorageService.initialize();
    log(
      'Storage init took: ${stopwatch.elapsedMilliseconds - startStorage} ms',
    );

    // 2. Đo Config (DotEnv)
    final startConfig = stopwatch.elapsedMilliseconds;
    await ConfigService.initialize();
    log('Config init took: ${stopwatch.elapsedMilliseconds - startConfig} ms');

    // 3. Đo API
    final startApi = stopwatch.elapsedMilliseconds;
    await ApiService.initialize();
    log('Api init took: ${stopwatch.elapsedMilliseconds - startApi} ms');

    log('--- END BOOTSTRAP: Total ${stopwatch.elapsedMilliseconds} ms ---');
    stopwatch.stop();
  }
}
