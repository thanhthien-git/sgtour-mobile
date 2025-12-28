import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';

class BiometricState {
  final bool isAvailable;
  final bool isEnabled;
  final bool isLoading;
  final String? error;
  final BiometricType? primaryBiometric;

  const BiometricState({
    this.isAvailable = false,
    this.isEnabled = false,
    this.isLoading = false,
    this.error,
    this.primaryBiometric,
  });

  BiometricState copyWith({
    bool? isAvailable,
    bool? isEnabled,
    bool? isLoading,
    String? error,
    BiometricType? primaryBiometric,
  }) {
    return BiometricState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      primaryBiometric: primaryBiometric ?? this.primaryBiometric,
    );
  }
}

final biometricServiceProvider = Provider((ref) => BiometricService());

final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>(
      (ref) => BiometricNotifier(ref),
    );

class BiometricNotifier extends StateNotifier<BiometricState> {
  final Ref _ref;
  late final BiometricService _biometricService;

  BiometricNotifier(this._ref) : super(const BiometricState()) {
    _biometricService = _ref.watch(biometricServiceProvider);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final primaryBiometric = await _biometricService.getPrimaryBiometric();

      state = state.copyWith(
        isAvailable: isAvailable,
        primaryBiometric: primaryBiometric,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> checkBiometricStatus(String userId) async {
    try {
      if (!state.isAvailable) return;

      final isEnabled = await _biometricService.isBiometricEnabled(userId);
      state = state.copyWith(isEnabled: isEnabled, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> authenticateWithBiometric(String reason) async {
    try {
      if (!state.isAvailable) {
        throw BiometricException('Biometric not available');
      }

      state = state.copyWith(isLoading: true, error: null);

      final isAuthenticated = await _biometricService.authenticate(
        reason: reason,
      );

      state = state.copyWith(isLoading: false);
      return isAuthenticated;
    } on BiometricException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Authentication failed');
      return false;
    }
  }

  Future<void> enableBiometric(String userId, String token) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final isAuthenticated = await _biometricService.authenticate(
        reason: 'Enable biometric authentication',
      );

      if (!isAuthenticated) {
        throw BiometricException('Authentication failed');
      }

      await _biometricService.storeBiometricToken(userId, token);
      state = state.copyWith(isEnabled: true, isLoading: false);
    } on BiometricException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to enable biometric',
      );
    }
  }

  Future<void> disableBiometric(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _biometricService.disableBiometric(userId);
      state = state.copyWith(isEnabled: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to disable biometric',
      );
    }
  }

  Future<String?> loginWithBiometric(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final isAuthenticated = await _biometricService.authenticate(
        reason: 'Login to your account',
      );

      if (!isAuthenticated) {
        throw BiometricException('Authentication failed');
      }

      final token = await _biometricService.getBiometricToken(userId);

      if (token == null) {
        throw BiometricException('No stored authentication found');
      }

      state = state.copyWith(isLoading: false);
      return token;
    } on BiometricException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed');
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
