import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../models/movie_model.dart';

/// MovieRepository'nin somut implementasyonu.
/// DioClient aracılığıyla TMDB API'sine istek atar.
class MovieRepositoryImpl implements MovieRepository {
  final DioClient _dioClient;

  MovieRepositoryImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<List<Movie>> getPopularMovies({required int page}) async {
    final response = await _dioClient.get(
      ApiConstants.popularMovies,
      queryParameters: {
        'page': page,
        'language': 'tr-TR',
      },
    );

    final List<dynamic> results = response.data['results'] ?? [];
    return results
        .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Movie>> searchMovies({
    required String query,
    required int page,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.searchMovies,
      queryParameters: {
        'query': query,
        'page': page,
        'language': 'tr-TR',
      },
    );

    final List<dynamic> results = response.data['results'] ?? [];
    return results
        .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
        .map((model) => model.toEntity())
        .toList();
  }
}
