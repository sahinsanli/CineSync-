/// Film Entity sınıfı — Uygulamanın saf çekirdek modeli.
/// Dış kaynaklara (API, DB) bağımlılığı yoktur.
class Movie {
  final String id;
  final String title;
  final String overview;
  final String posterPath;
  final DateTime releaseDate;
  final double rating;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
  });

  /// API'den gelen karmaşık tarihi ekranda sadece yıl olarak göstermek için getter
  String get releaseYear => releaseDate.year.toString();

  /// TMDB poster URL'ini oluşturmak için getter
  String get fullPosterUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
}
