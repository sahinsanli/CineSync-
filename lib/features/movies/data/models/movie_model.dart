import '../../domain/entities/movie.dart';

/// TMDB API'den gelen JSON verisini karşılayan Data Transfer Object (DTO).
/// API'nin ham verisini parse eder ve toEntity() ile saf Entity'ye dönüştürür.
class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;

  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.releaseDate,
    required this.voteAverage,
  });

  /// TMDB API'den gelen JSON'u MovieModel'e dönüştürür.
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
    );
  }

  /// DTO'yu uygulamanın saf çekirdek modeli olan Movie Entity'sine dönüştürür.
  Movie toEntity() {
    return Movie(
      id: id.toString(),
      title: title,
      overview: overview,
      posterPath: posterPath ?? '',
      releaseDate:
          DateTime.tryParse(releaseDate ?? '') ?? DateTime(2000),
      rating: voteAverage,
    );
  }
}
