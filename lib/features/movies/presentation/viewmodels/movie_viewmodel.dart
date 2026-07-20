import 'package:flutter/foundation.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../../../core/error/app_exception.dart';

/// Film ViewModel — ChangeNotifier ile state yönetimi.
/// Provider aracılığıyla UI katmanına sunulur.
class MovieViewModel extends ChangeNotifier {
  final MovieRepository _repository;

  MovieViewModel({required MovieRepository repository})
      : _repository = repository;

  // State alanları
  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  // Getter'lar
  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  /// Popüler filmleri ilk sayfa olarak yükler.
  Future<void> loadPopularMovies() async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _searchQuery = '';
    notifyListeners();

    try {
      final movies = await _repository.getPopularMovies(page: _currentPage);
      _movies = movies;
      _hasMore = movies.length >= 20; // TMDB sayfa başına 20 film döner
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Beklenmeyen bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sonraki sayfayı yükler (Infinite Scroll).
  Future<void> loadMoreMovies() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      final List<Movie> newMovies;

      if (_searchQuery.isNotEmpty) {
        newMovies = await _repository.searchMovies(
          query: _searchQuery,
          page: _currentPage,
        );
      } else {
        newMovies = await _repository.getPopularMovies(page: _currentPage);
      }

      _movies.addAll(newMovies);
      _hasMore = newMovies.length >= 20;
    } on AppException catch (e) {
      _error = e.message;
      _currentPage--; // Sayfa geri al, tekrar denenebilsin
    } catch (e) {
      _error = 'Beklenmeyen bir hata oluştu: $e';
      _currentPage--;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Film araması yapar.
  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      await loadPopularMovies();
      return;
    }

    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _searchQuery = query.trim();
    notifyListeners();

    try {
      final movies = await _repository.searchMovies(
        query: _searchQuery,
        page: _currentPage,
      );
      _movies = movies;
      _hasMore = movies.length >= 20;
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Beklenmeyen bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hata mesajını temizler.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
