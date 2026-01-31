import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sgtourcus/services/file/storage_service.dart';
import 'package:sgtourcus/services/file/config_service.dart';

class ApiService {
  late final Dio _dio;
  static late String _baseUrl;

  static Future<void> initialize() async {
    _baseUrl = ConfigService.instance.apiBaseUrl;
    // Empty is allowed so the app can start without .env; requests will throw later
  }

  ApiService() {
    final baseUrl = _baseUrl.isEmpty
        ? 'https://invalid.local'
        : _baseUrl;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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
    handler.next(response);
  }

  // Interceptor: Error
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    handler.next(err);
  }

  void _ensureBaseUrl() {
    if (_baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is empty. Add it to .env (see .env.example) or configure ConfigService.',
      );
    }
  }

  // GET Request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _ensureBaseUrl();
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
    _ensureBaseUrl();
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
    _ensureBaseUrl();
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
    _ensureBaseUrl();
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
    _ensureBaseUrl();
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
