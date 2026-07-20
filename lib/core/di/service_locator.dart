import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../services/firestore_service.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/data/repositories/firestore_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/movies/domain/repositories/firestore_repository.dart';
import '../../features/movies/presentation/viewmodels/movie_viewmodel.dart';
import '../../features/movies/presentation/viewmodels/firestore_viewmodel.dart';

/// Global ServiceLocator instance.
final getIt = GetIt.instance;

/// Tüm bağımlılıkları kayıt eder.
/// main() içinde uygulama başlamadan önce çağrılmalıdır.
void setupServiceLocator() {
  // Core — Network
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Core — Firestore
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());

  // Repository — TMDB API
  getIt.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(dioClient: getIt<DioClient>()),
  );

  // Repository — Firestore
  getIt.registerLazySingleton<FirestoreRepository>(
    () => FirestoreRepositoryImpl(firestoreService: getIt<FirestoreService>()),
  );

  // ViewModel — Movie (TMDB API)
  getIt.registerFactory<MovieViewModel>(
    () => MovieViewModel(repository: getIt<MovieRepository>()),
  );

  // ViewModel — Firestore (Watchlist, Favorites, Reviews)
  getIt.registerFactory<FirestoreViewModel>(
    () => FirestoreViewModel(
      repository: getIt<FirestoreRepository>(),
      firestoreService: getIt<FirestoreService>(),
    ),
  );
}
