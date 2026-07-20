import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/movie.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'movie_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    // Sayfa yüklendiğinde popüler filmleri çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieViewModel>().loadPopularMovies();
    });

    // Infinite scroll: Listenin sonuna yaklaşınca sonraki sayfayı yükle
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MovieViewModel>().loadMoreMovies();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Film ara...',
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  context.read<MovieViewModel>().searchMovies(query);
                },
              )
            : const Text('Keşfet'),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  context.read<MovieViewModel>().loadPopularMovies();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      // Consumer ile sadece film listesi değiştiğinde rebuild olur
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          // İlk yükleme sırasında loading göster
          if (viewModel.isLoading && viewModel.movies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hata varsa ve liste boşsa hata göster
          if (viewModel.error != null && viewModel.movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadPopularMovies(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          // Film yoksa boş durum göster
          if (viewModel.movies.isEmpty) {
            return const Center(
              child: Text(
                'Film bulunamadı.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // Film listesi — ListView.builder ile lazy rendering
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            // Eğer daha fazla film varsa, listenin sonuna loading göstermek için +1
            itemCount: viewModel.movies.length + (viewModel.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Son eleman: loading indicator
              if (index >= viewModel.movies.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final movie = viewModel.movies[index];
              return _MovieCard(movie: movie);
            },
          );
        },
      ),
    );
  }
}

/// Film kartı widget'ı — Overflow hatalarına karşı Flexible/Expanded kullanır.
class _MovieCard extends StatelessWidget {
  final Movie movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        child: Row(
          children: [
            // Poster
            SizedBox(
              width: 80,
              height: 120,
              child: movie.posterPath.isNotEmpty
                  ? Image.network(
                      movie.fullPosterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child:
                            const Icon(Icons.movie, color: Colors.white54),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.white54),
                    ),
            ),
            // Film bilgileri — Expanded ile overflow engellenir
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık — uzun metinler taşmaz
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Yıl ve puan
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${movie.releaseYear} • ⭐ ${movie.rating.toStringAsFixed(1)}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Özet — en fazla 2 satır
                    Text(
                      movie.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
