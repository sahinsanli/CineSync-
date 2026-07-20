import '../entities/movie.dart';

/// Film veri kaynağını soyutlayan abstract repository arayüzü.
/// İş mantığını dış dünyadan (API, DB) izole eder.
abstract class MovieRepository {
  /// Popüler filmleri sayfalama ile getirir.
  Future<List<Movie>> getPopularMovies({required int page});

  /// Film araması yapar. [query] arama metni, [page] sayfa numarası.
  Future<List<Movie>> searchMovies({
    required String query,
    required int page,
  });
}
