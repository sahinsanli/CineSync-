import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/di/service_locator.dart';
import 'features/movies/presentation/viewmodels/movie_viewmodel.dart';
import 'features/movies/presentation/viewmodels/firestore_viewmodel.dart';
import 'features/movies/presentation/screens/discover_screen.dart';
import 'features/movies/presentation/screens/watchlist_screen.dart';
import 'features/movies/presentation/screens/profile_screen.dart';
import 'auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Dependency Injection — tüm bağımlılıkları kayıt et
  setupServiceLocator();

  runApp(const CineSyncApp());
}

class CineSyncApp extends StatelessWidget {
  const CineSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<MovieViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<FirestoreViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'CineSync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// Kullanıcının giriş durumunu dinler.
/// Giriş yapılmadıysa LoginScreen, yapıldıysa MainScreen gösterilir.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Bağlantı beklenirken loading göster
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kullanıcı giriş yapmışsa ana ekranı göster
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // Giriş yapılmamışsa login ekranını göster
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ana ekran açıldığında Watchlist ve Profil istatistikleri stream'lerini başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<FirestoreViewModel>();
      vm.listenToWatchlist();
      vm.listenToProfileStats();
    });
  }

  // Bottom Navigation Bar'daki 3 ana ekran
  final List<Widget> _screens = const [
    DiscoverScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'İzleme Listem',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
