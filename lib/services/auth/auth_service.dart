import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sgtour_mobile/services/file/config_service.dart';
import '../../api/api_service.dart';
import '../file/storage_service.dart';

class AuthService {
  final ApiService api;
  final GoogleSignIn _googleSignIn;

  AuthService()
    : api = ApiService(),
      _googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId: ConfigService.instance.googleWebClientId,
      );

  factory AuthService.fromApi({required ApiService api}) {
    final id = ConfigService.instance.googleWebClientId;
    if (id.isEmpty) {
      throw StateError('GOOGLE_WEB_CLIENT_ID is required for Google Sign-In');
    }
    return AuthService();
  }

  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
    String typeUser = 'customer',
  }) async {
    final payload = <String, dynamic>{
      'typeUser': typeUser,
      'password': password,
    };
    if (email != null) payload['email'] = email;
    if (phone != null) payload['phone'] = phone;

    final response = await api.post('/auth/login', data: payload);
    return _handleAuthResponse(response);
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    String? idToken,
    String typeUser = 'customer',
  }) async {
    try {
      final account = await _googleSignIn.signIn();
      debugPrint('ACCOUNT: $account');
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In Error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    idToken ??= (await _googleSignIn.currentUser?.authentication)?.idToken;

    final response = await api.post(
      '/auth/login/google',
      data: {'idToken': idToken, 'typeUser': typeUser},
    );

    return _handleAuthResponse(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phoneOrEmail,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'phoneOrEmail': phoneOrEmail,
      'password': password,
    };

    final response = await api.post('/auth/register', data: payload);

    return _handleAuthResponse(response);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await StorageService.instance.remove([
      StorageKeys.authToken,
      StorageKeys.userId,
    ]);
  }

  Map<String, dynamic> _handleAuthResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final token = data['accessToken'];

      if (token is String) {
        StorageService.instance.setString(StorageKeys.authToken, token);

        final decodedToken = JwtDecoder.decode(token);
        if (decodedToken['sub'] != null) {
          StorageService.instance.setString(
            StorageKeys.userId,
            decodedToken['sub'],
          );
        }
      }

      return Map<String, dynamic>.from(data);
    }

    return {'data': data};
  }
}
