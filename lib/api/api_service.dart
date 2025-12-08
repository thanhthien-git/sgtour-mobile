import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        sendTimeout: Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // Interceptor: Request
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      print('📤 REQUEST: ${options.method} ${options.path}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Data: ${options.data}');
      }
    }
    handler.next(options);
  }

  // Interceptor: Response
  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      print('Data: ${response.data}');
    }
    handler.next(response);
  }

  // Interceptor: Error
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      print('❌ ERROR: ${err.message}');
      print('Status: ${err.response?.statusCode}');
    }
    handler.next(err);
  }

  // GET Request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
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
      default:
        return 'An error occurred';
    }
  }
}
