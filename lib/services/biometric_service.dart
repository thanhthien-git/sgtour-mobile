import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum BiometricType { fingerprint, face, iris, unknown }

class BiometricException implements Exception {
  final String message;
  final String? code;

  BiometricException(this.message, {this.code});

  @override
  String toString() => message;
}

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  late final LocalAuthentication _localAuth;
  late final FlutterSecureStorage _secureStorage;

  factory BiometricService() {
    return _instance;
  }

  BiometricService._internal() {
    _localAuth = LocalAuthentication();
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        keyCipherAlgorithm:
            KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
  }

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final isDeviceSupported = await _localAuth.canCheckBiometrics;
      return isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.map((b) {
        if (b == BiometricType.face) return BiometricType.face;
        if (b == BiometricType.fingerprint) return BiometricType.fingerprint;
        if (b == BiometricType.iris) return BiometricType.iris;
        return BiometricType.unknown;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get the primary biometric type available
  Future<BiometricType?> getPrimaryBiometric() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) return null;

    // Prefer face auth, then fingerprint
    if (biometrics.contains(BiometricType.face)) {
      return BiometricType.face;
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    }
    return biometrics.first;
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({
    required String reason,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw BiometricException(
          'Biometric authentication is not available on this device',
        );
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
      );

      return isAuthenticated;
    } catch (e) {
      throw BiometricException('Authentication failed: $e');
    }
  }

  /// Store biometric-authenticated token securely
  Future<void> storeBiometricToken(String userId, String token) async {
    try {
      await _secureStorage.write(key: 'biometric_token_$userId', value: token);
      await _secureStorage.write(
        key: 'biometric_enabled_$userId',
        value: 'true',
      );
    } catch (e) {
      throw BiometricException('Failed to store biometric token: $e');
    }
  }

  /// Retrieve biometric-authenticated token
  Future<String?> getBiometricToken(String userId) async {
    try {
      final token = await _secureStorage.read(key: 'biometric_token_$userId');
      return token;
    } catch (e) {
      throw BiometricException('Failed to retrieve biometric token: $e');
    }
  }

  /// Check if biometric is enabled for user
  Future<bool> isBiometricEnabled(String userId) async {
    try {
      final enabled = await _secureStorage.read(
        key: 'biometric_enabled_$userId',
      );
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Disable biometric authentication for user
  Future<void> disableBiometric(String userId) async {
    try {
      await _secureStorage.delete(key: 'biometric_token_$userId');
      await _secureStorage.delete(key: 'biometric_enabled_$userId');
    } catch (e) {
      throw BiometricException('Failed to disable biometric: $e');
    }
  }

  /// Clear all biometric data
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw BiometricException('Failed to clear biometric data: $e');
    }
  }
}
