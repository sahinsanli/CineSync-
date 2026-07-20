import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/review.dart';
import '../viewmodels/firestore_viewmodel.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 3.0;

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında favori, watchlist ve yorum durumlarını başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FirestoreViewModel>().initForMovie(widget.movie);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        actions: [
          // Beğen butonu (kalp ikonu)
          Consumer<FirestoreViewModel>(
            builder: (context, vm, child) {
              return IconButton(
                icon: Icon(
                  vm.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: vm.isFavorite ? Colors.red : null,
                ),
                onPressed: () => vm.toggleFavorite(widget.movie),
                tooltip: 'Beğen',
              );
            },
          ),
          // İzleme listesine ekle butonu (bookmark ikonu)
          Consumer<FirestoreViewModel>(
            builder: (context, vm, child) {
              return IconButton(
                icon: Icon(
                  vm.isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                  color: vm.isInWatchlist ? Colors.amber : null,
                ),
                onPressed: () => vm.toggleWatchlist(widget.movie),
                tooltip: 'İzleme Listesine Ekle',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster alanı — TMDB'den gerçek poster
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.movie.posterPath.isNotEmpty
                    ? Image.network(
                        widget.movie.fullPosterUrl,
                        width: 200,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 200,
                          height: 300,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.movie_creation,
                            size: 64,
                            color: Colors.white54,
                          ),
                        ),
                      )
                    : Container(
                        width: 200,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.movie_creation,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Film başlığı
            Text(
              widget.movie.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Vizyon tarihi ve puan
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.movie.releaseYear,
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  widget.movie.rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Özet
            Text(
              'Özet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.movie.overview.isNotEmpty
                  ? widget.movie.overview
                  : 'Bu film için Türkçe özet bulunmamaktadır.',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),

            // ─── YORUM YAZMA ALANI ─────────────────────────────
            Text(
              'Yorum Yaz',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Puan seçici
            Row(
              children: [
                const Text('Puanın: ', style: TextStyle(color: Colors.grey)),
                ...List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return GestureDetector(
                    onTap: () => setState(() => _userRating = starValue),
                    child: Icon(
                      starValue <= _userRating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 28,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${_userRating.toInt()}/5',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Yorum giriş alanı
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Yorumunuzu yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<FirestoreViewModel>(
                  builder: (context, vm, child) {
                    return IconButton.filled(
                      onPressed: vm.isLoading
                          ? null
                          : () {
                              final comment = _commentController.text.trim();
                              if (comment.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Yorum boş olamaz.'),
                                  ),
                                );
                                return;
                              }
                              vm.addReview(
                                movie: widget.movie,
                                comment: comment,
                                rating: _userRating,
                              );
                              _commentController.clear();
                              FocusScope.of(context).unfocus();
                            },
                      icon: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── YORUMLAR LİSTESİ ──────────────────────────────
            Text(
              'Yorumlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            Consumer<FirestoreViewModel>(
              builder: (context, vm, child) {
                if (vm.reviews.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.comment, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Henüz yorum yok.\nİlk yorumu sen yap!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vm.reviews.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return _ReviewCard(review: vm.reviews[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir yorum kartı widget'ı.
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı adı ve puan
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Yıldız puanı
              ...List.generate(5, (i) {
                return Icon(
                  i < review.rating.round() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ],
          ),
          const SizedBox(height: 4),
          // Yorum metni
          Text(
            review.comment,
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 4),
          // Tarih
          Text(
            _formatDate(review.createdAt),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
