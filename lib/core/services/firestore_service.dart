import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore ile doğrudan iletişim kuran servis sınıfı.
/// Repository katmanı tarafından kullanılır.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── WATCHLIST ───────────────────────────────────────────

  /// Filmi kullanıcının izleme listesine ekler.
  Future<void> addToWatchlist(String userId, Map<String, dynamic> movieData) async {
    final movieId = movieData['movieId'] as String;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId)
        .set({
      ...movieData,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Filmi kullanıcının izleme listesinden çıkarır.
  Future<void> removeFromWatchlist(String userId, String movieId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId)
        .delete();
  }

  /// Kullanıcının izleme listesini canlı stream olarak döner.
  Stream<QuerySnapshot> getWatchlistStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  /// Filmin izleme listesinde olup olmadığını kontrol eder.
  Future<bool> isInWatchlist(String userId, String movieId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId)
        .get();
    return doc.exists;
  }

  // ─── FAVORITES (BEĞENİ) ─────────────────────────────────

  /// Filmi beğenme durumunu tersine çevirir (toggle).
  Future<bool> toggleFavorite(String userId, String movieId, String movieTitle) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(movieId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
      return false; // Beğeni kaldırıldı
    } else {
      await docRef.set({
        'movieId': movieId,
        'title': movieTitle, // Konsolda okunabilir olması için eklendi
        'addedAt': FieldValue.serverTimestamp(),
      });
      return true; // Beğenildi
    }
  }

  /// Filmin beğenilip beğenilmediğini kontrol eder.
  Future<bool> isFavorite(String userId, String movieId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(movieId)
        .get();
    return doc.exists;
  }

  /// Kullanıcının toplam beğeni (favori) sayısını canlı stream olarak döner.
  Stream<int> getFavoritesCountStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Kullanıcının toplam yorum sayısını hesaplamak için tüm filmlerdeki
  /// yorumları tarayıp userId'ye göre filtreleme yapmak gerekir.
  /// Ancak Firestore'da cross-collection sorgu olmadığı için,
  /// bu sayıyı kullanıcı dokümanında tutacağız (artımlı sayaç).
  Future<void> incrementReviewCount(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'reviewCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Kullanıcının yorum sayısını canlı stream olarak döner.
  Stream<int> getReviewCountStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null) return 0;
      return (data['reviewCount'] as int?) ?? 0;
    });
  }

  // ─── REVIEWS (YORUMLAR) ──────────────────────────────────

  /// Bir filme yorum ekler.
  Future<void> addReview(String movieId, Map<String, dynamic> reviewData) async {
    await _firestore
        .collection('movies')
        .doc(movieId)
        .collection('reviews')
        .add({
      ...reviewData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Bir filmin yorumlarını canlı stream olarak döner.
  Stream<QuerySnapshot> getReviewsStream(String movieId) {
    return _firestore
        .collection('movies')
        .doc(movieId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
