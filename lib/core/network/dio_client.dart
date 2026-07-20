import 'package:dio/dio.dart';
import 'api_constants.dart';
import '../error/app_exception.dart';

/// Dio HTTP istemcisi.
/// Interceptor ile her isteğe otomatik API key ekler
/// ve hata kodlarına göre AppException fırlatır.
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Interceptor: Her isteğe API key'i query parameter olarak ekle
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Her giden isteğe otomatik api_key parametresi ekle
          options.queryParameters['api_key'] = ApiConstants.apiKey;
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
      ),
    );
  }

  /// GET isteği atar ve Response döner.
  /// HTTP hatalarını AppException'a dönüştürür.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw const UnauthorizedException();
      } else if (statusCode == 404) {
        throw const NotFoundException();
      } else if (statusCode != null && statusCode >= 500) {
        throw ServerException('Sunucu hatası (HTTP $statusCode)', statusCode);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(
        'Bağlantı hatası: ${e.message ?? e.type.name}',
        statusCode,
      );
    }
  }
}
