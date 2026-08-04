import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    String message = error.message ?? 'Network error';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message =
            'Sunucu yanıt vermedi. IP adresini ve backend\'in çalıştığını kontrol edin.';
      case DioExceptionType.connectionError:
        message =
            'Sunucuya bağlanılamadı. Aynı Wi-Fi ağında olduğunuzdan ve adresin doğru olduğundan emin olun.';
      case DioExceptionType.badResponse:
        break;
      default:
        break;
    }

    if (response?.data is Map) {
      final map = response!.data as Map;
      message = map['message']?.toString() ??
          map['error']?.toString() ??
          message;
    }

    return ApiException(
      message: message,
      statusCode: response?.statusCode,
      data: response?.data,
    );
  }

  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
