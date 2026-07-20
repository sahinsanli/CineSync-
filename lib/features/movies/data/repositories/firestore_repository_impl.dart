import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/firestore_repository.dart';

/// FirestoreRepository'nin somut implementasyonu.
/// FirestoreService'i kullanarak Firestore işlemlerini gerçekleştirir.
class FirestoreRepositoryImpl implements FirestoreRepository {
  final FirestoreService _firestoreService;

  FirestoreRepositoryImpl({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  // ─── WATCHLIST ─────────────────────────────────────────────

  @override
  Future<void> addToWatchlist(String userId, Movie movie) async {
    await _firestoreService.addToWatchlist(userId, {
      'movieId': movie.id, // UID bazlı çalışırken ID mutlaka kaydedilir
      'title': movie.title, // Konsol okunabilirliği için eklendi
      'posterPath': movie.posterPath,
      'rating': movie.rating,
      'releaseDate': movie.releaseDate.toIso8601String(),
      'overview': movie.overview,
    });
  }

  @override
  Future<void> removeFromWatchlist(String userId, String movieId) async {
    await _firestoreService.removeFromWatchlist(userId, movieId);
  }

  @override
  Stream<List<Movie>> watchlistStream(String userId) {
    return _firestoreService.getWatchlistStream(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie(
          id: data['movieId'] ?? doc.id,
          title: data['title'] ?? '',
          overview: data['overview'] ?? '',
          posterPath: data['posterPath'] ?? '',
          releaseDate: DateTime.tryParse(data['releaseDate'] ?? '') ?? DateTime.now(),
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    });
  }

  @override
  Future<bool> isInWatchlist(String userId, String movieId) async {
    return _firestoreService.isInWatchlist(userId, movieId);
  }

  // ─── FAVORITES ─────────────────────────────────────────────

  @override
  Future<bool> toggleFavorite(String userId, String movieId, String movieTitle) async {
    return _firestoreService.toggleFavorite(userId, movieId, movieTitle);
  }

  @override
  Future<bool> isFavorite(String userId, String movieId) async {
    return _firestoreService.isFavorite(userId, movieId);
  }

  // ─── REVIEWS ───────────────────────────────────────────────

  @override
  Future<void> addReview({
    required String movieId,
    required String userId,
    required String userName,
    required String comment,
    required double rating,
  }) async {
    await _firestoreService.addReview(movieId, {
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
    });
  }

  @override
  Stream<List<Review>> reviewsStream(String movieId) {
    return _firestoreService.getReviewsStream(movieId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Review(
          id: doc.id,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? 'Anonim',
          comment: data['comment'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }
}
