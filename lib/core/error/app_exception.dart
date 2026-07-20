/// Uygulama genelinde kullanılan hata hiyerarşisi.
/// Dart 3 sealed class yapısıyla oluşturulmuştur.
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Ağ bağlantısı hatası (timeout, internet yok vb.)
class NetworkException extends AppException {
  const NetworkException([super.message = 'Ağ bağlantısı hatası oluştu.']);
}

/// Sunucu hatası (500 vb.)
class ServerException extends AppException {
  const ServerException([
    super.message = 'Sunucu hatası oluştu.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

/// Yetkilendirme hatası (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Yetkilendirme hatası. API anahtarınızı kontrol edin.',
  ]) : super(statusCode: 401);
}

/// Kaynak bulunamadı (404)
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'Aradığınız kaynak bulunamadı.',
  ]) : super(statusCode: 404);
}
