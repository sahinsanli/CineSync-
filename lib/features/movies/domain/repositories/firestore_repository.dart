import '../entities/movie.dart';
import '../entities/review.dart';

/// Firestore işlemleri için abstract repository.
/// Data katmanındaki concrete sınıf tarafından implemente edilecek.
abstract class FirestoreRepository {
  // ─── WATCHLIST ─────────────────────────────────────────────
  Future<void> addToWatchlist(String userId, Movie movie);
  Future<void> removeFromWatchlist(String userId, String movieId);
  Stream<List<Movie>> watchlistStream(String userId);
  Future<bool> isInWatchlist(String userId, String movieId);

  // ─── FAVORITES ─────────────────────────────────────────────
  Future<bool> toggleFavorite(String userId, String movieId, String movieTitle);
  Future<bool> isFavorite(String userId, String movieId);

  // ─── REVIEWS ───────────────────────────────────────────────
  Future<void> addReview({
    required String movieId,
    required String userId,
    required String userName,
    required String comment,
    required double rating,
  });
  Stream<List<Review>> reviewsStream(String movieId);
}
