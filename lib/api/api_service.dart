import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sgtour_mobile/services/storage_service.dart';
import 'package:sgtour_mobile/services/config_service.dart';

class ApiService {
  late final Dio _dio;
  static late String _baseUrl;

  static Future<void> initialize() async {
    final baseUrl = ConfigService.instance.apiBaseUrl;
    if (baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is empty. Did you forget to load .env or ConfigService?',
      );
    }
    _baseUrl = baseUrl;
  }

  ApiService() {
    if (_baseUrl.isEmpty) {
      throw StateError(
        'ApiService not initialized. Call ApiService.initialize() before using it.',
      );
    }
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _onRequest(options, handler);
        },
        onResponse: (response, handler) async {
          await _onResponse(response, handler);
        },
        onError: (err, handler) async {
          await _onError(err, handler);
        },
      ),
    );
  }

  // Interceptor: Request
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.startsWith('http')) {
      return handler.next(options);
    }

    try {
      final token = StorageService.instance.getString(StorageKeys.authToken);
      if (_isValidJwt(token)) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    handler.next(options);
  }

  bool _isValidJwt(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  ConfigService get config => ConfigService.instance;

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint(
        'RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
      );
      debugPrint('Data: ${response.data}');
    }
    handler.next(response);
  }

  // Interceptor: Error
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint('ERROR URL: ${err.requestOptions.path}');
      debugPrint('ERROR MSG: ${err.message}');
      debugPrint('Status: ${err.response?.statusCode}');
      debugPrint('Response Data: ${err.response?.data}');
    }
    handler.next(err);
  }

  // GET Request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String endpoint, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String endpoint, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
    String endpoint, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handling
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Bad response: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.unknown:
        return 'Lỗi không xác định: ${error.message} (Chi tiết: ${error.error})';

      default:
        return 'Lỗi lạ: ${error.message}';
    }
  }
}
