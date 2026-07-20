import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/firestore_repository.dart';
import '../../../../core/services/firestore_service.dart';

/// Firestore işlemleri için ViewModel.
/// Watchlist, favorite ve review state yönetimini sağlar.
class FirestoreViewModel extends ChangeNotifier {
  final FirestoreRepository _repository;
  final FirestoreService _firestoreService;

  FirestoreViewModel({
    required FirestoreRepository repository,
    required FirestoreService firestoreService,
  })  : _repository = repository,
        _firestoreService = firestoreService;

  // ─── STATE ALANLARI ────────────────────────────────────────

  // Watchlist
  List<Movie> _watchlist = [];
  List<Movie> get watchlist => _watchlist;
  StreamSubscription? _watchlistSub;

  // Favorites
  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  // Reviews
  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;
  StreamSubscription? _reviewsSub;

  // Loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // İzleme listesi durumu
  bool _isInWatchlist = false;
  bool get isInWatchlist => _isInWatchlist;

  // ─── PROFİL İSTATİSTİKLERİ ─────────────────────────────────

  int _favoritesCount = 0;
  int get favoritesCount => _favoritesCount;
  StreamSubscription? _favoritesCountSub;

  int _reviewsCount = 0;
  int get reviewsCount => _reviewsCount;
  StreamSubscription? _reviewsCountSub;

  /// Watchlist sayısı zaten _watchlist.length'den alınabilir.
  int get watchlistCount => _watchlist.length;

  /// Mevcut kullanıcının isim soyismini döner (Firebase profilindeki displayName).
  String get _userName {
    final name = FirebaseAuth.instance.currentUser?.displayName;
    if (name == null || name.isEmpty) return 'Anonim';
    return name;
  }
  
  /// Mevcut kullanıcının uid'sini döner
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // ─── WATCHLIST ─────────────────────────────────────────────

  /// Kullanıcının watchlist stream'ini dinlemeye başlar.
  void listenToWatchlist() {
    final uid = _userId;
    if (uid == null) return;

    _watchlistSub?.cancel();
    _watchlistSub = _repository.watchlistStream(uid).listen((movies) {
      _watchlist = movies;
      notifyListeners();
    });
  }

  /// Filmi izleme listesine ekler veya çıkarır.
  Future<void> toggleWatchlist(Movie movie) async {
    final uid = _userId;
    if (uid == null) return;

    if (_isInWatchlist) {
      await _repository.removeFromWatchlist(uid, movie.id);
      _isInWatchlist = false;
    } else {
      await _repository.addToWatchlist(uid, movie);
      _isInWatchlist = true;
    }
    notifyListeners();
  }

  /// Filmin watchlist durumunu kontrol eder.
  Future<void> checkWatchlistStatus(Movie movie) async {
    final uid = _userId;
    if (uid == null) return;

    _isInWatchlist = await _repository.isInWatchlist(uid, movie.id);
    notifyListeners();
  }

  // ─── FAVORITES ─────────────────────────────────────────────

  /// Filmi beğenme/beğenmeme toggle.
  Future<void> toggleFavorite(Movie movie) async {
    final uid = _userId;
    if (uid == null) return;

    _isFavorite = await _repository.toggleFavorite(uid, movie.id, movie.title);
    notifyListeners();
  }

  /// Filmin beğeni durumunu kontrol eder.
  Future<void> checkFavoriteStatus(Movie movie) async {
    final uid = _userId;
    if (uid == null) return;

    _isFavorite = await _repository.isFavorite(uid, movie.id);
    notifyListeners();
  }

  // ─── REVIEWS ───────────────────────────────────────────────

  /// Bir filmin yorumlarını dinlemeye başlar.
  void listenToReviews(Movie movie) {
    _reviewsSub?.cancel();
    _reviewsSub = _repository.reviewsStream(movie.id).listen((reviews) {
      _reviews = reviews;
      notifyListeners();
    });
  }

  /// Yeni yorum ekler.
  Future<void> addReview({
    required Movie movie,
    required String comment,
    required double rating,
  }) async {
    final uid = _userId;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    await _repository.addReview(
      movieId: movie.id,
      userId: uid,
      userName: _userName, // Okunabilirlik için
      comment: comment,
      rating: rating,
    );

    // Kullanıcının toplam yorum sayısını artır
    await _firestoreService.incrementReviewCount(uid);

    _isLoading = false;
    notifyListeners();
  }

  // ─── PROFİL İSTATİSTİKLERİ DİNLEME ────────────────────────

  /// Profil ekranı için favori ve yorum sayısı stream'lerini başlatır.
  void listenToProfileStats() {
    final uid = _userId;
    if (uid == null) return;

    // Favori sayısını dinle
    _favoritesCountSub?.cancel();
    _favoritesCountSub = _firestoreService.getFavoritesCountStream(uid).listen((count) {
      _favoritesCount = count;
      notifyListeners();
    });

    // Yorum sayısını dinle
    _reviewsCountSub?.cancel();
    _reviewsCountSub = _firestoreService.getReviewCountStream(uid).listen((count) {
      _reviewsCount = count;
      notifyListeners();
    });
  }

  // ─── LIFECYCLE ─────────────────────────────────────────────

  /// Film detay ekranı için tüm durumları başlatır.
  void initForMovie(Movie movie) {
    checkFavoriteStatus(movie);
    checkWatchlistStatus(movie);
    listenToReviews(movie);
  }

  @override
  void dispose() {
    _watchlistSub?.cancel();
    _reviewsSub?.cancel();
    _favoritesCountSub?.cancel();
    _reviewsCountSub?.cancel();
    super.dispose();
  }
}
