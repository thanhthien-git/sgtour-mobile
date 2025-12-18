import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/services/storage_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthState {
  final bool isAuthenticated;
  final bool checked;
  const AuthState({required this.isAuthenticated, required this.checked});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
    : super(const AuthState(isAuthenticated: false, checked: false)) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await StorageService.initialize();
    final token = StorageService.instance.getString(StorageKeys.authToken);
    final valid = token != null && token.isNotEmpty && !_isExpired(token);
    state = AuthState(isAuthenticated: valid, checked: true);
  }

  bool _isExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }

  void logout() async {
    await StorageService.instance.remove(StorageKeys.authToken);
    state = const AuthState(isAuthenticated: false, checked: true);
  }
}
