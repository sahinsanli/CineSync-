import 'package:flutter_dotenv/flutter_dotenv.dart';

/// TMDB API sabitleri
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // TMDB API Anahtarı
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? '';

  // TMDB Bearer Token (API Okuma Erişim Jetonu)
  static String get bearerToken => dotenv.env['TMDB_BEARER_TOKEN'] ?? '';

  // Endpoint'ler
  static const String popularMovies = '/movie/popular';
  static const String searchMovies = '/search/movie';
}
