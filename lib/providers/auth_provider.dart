import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sgtour_mobile/services/storage_service.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    final token = StorageService.instance.getString(StorageKeys.authToken);

    if (token == null || token.isEmpty) return false;

    return !_isExpired(token);
  }

  bool _isExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await StorageService.instance.remove([
        StorageKeys.authToken,
        StorageKeys.userId,
      ]);
      return false;
    });
  }

  Future<void> loginSuccess() async {
    state = const AsyncValue.data(true);
  }
}
