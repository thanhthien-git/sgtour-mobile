import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _prefix = '🔵';
  static const String _errorPrefix = '🔴';
  static const String _warningPrefix = '🟡';
  static const String _successPrefix = '🟢';

  static void log(String message) {
    if (kDebugMode) {
      print('$_prefix $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_errorPrefix ERROR: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('$_warningPrefix WARNING: $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('$_successPrefix SUCCESS: $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('$_prefix DEBUG: $message');
    }
  }
}
