import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/movie.dart';
import '../viewmodels/firestore_viewmodel.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İzleme Listem'),
        centerTitle: true,
      ),
      // Consumer ile Firestore watchlist verisi dinleniyor
      body: Consumer<FirestoreViewModel>(
        builder: (context, vm, child) {
          if (vm.watchlist.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'İzleme listen boş',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Filmleri kaydetmek için Keşfet ekranından\nbir film seçip bookmark ikonuna bas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Watchlist'teki filmleri listele — ListView.builder ile lazy rendering
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: vm.watchlist.length,
            itemBuilder: (context, index) {
              final movie = vm.watchlist[index];
              return _WatchlistCard(movie: movie);
            },
          );
        },
      ),
    );
  }
}

/// Watchlist'teki film kartı widget'ı.
class _WatchlistCard extends StatelessWidget {
  final Movie movie;

  const _WatchlistCard({required this.movie});

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
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.white54),
                    ),
            ),
            // Film bilgileri
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
            // Watchlist'ten kaldır butonu
            IconButton(
              icon: const Icon(Icons.bookmark_remove, color: Colors.amber),
              onPressed: () {
                context.read<FirestoreViewModel>().toggleWatchlist(movie);
              },
              tooltip: 'Listeden Kaldır',
            ),
          ],
        ),
      ),
    );
  }
}
