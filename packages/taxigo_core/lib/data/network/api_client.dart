import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    SharedPreferences? prefs,
    String? baseUrl,
  })  : _prefs = prefs,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AppConstants.baseUrl,
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 12),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _token ?? await _loadToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.reject(error);
        },
      ),
    );
  }

  final Dio _dio;
  final SharedPreferences? _prefs;
  String? _token;

  Dio get dio => _dio;

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  Future<String?> _loadToken() async {
    _token = _prefs?.getString(AppConstants.authTokenKey);
    return _token;
  }

  Future<void> setAuthToken(String? token) async {
    _token = token;
    if (token == null) {
      await _prefs?.remove(AppConstants.authTokenKey);
    } else {
      await _prefs?.setString(AppConstants.authTokenKey, token);
    }
  }

  Future<String?> getAuthToken() async {
    return _token ?? await _loadToken();
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
