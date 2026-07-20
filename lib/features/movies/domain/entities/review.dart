/// Yorum Entity sınıfı — Kullanıcı yorumlarını temsil eder.
/// Firestore'dan bağımsız, saf domain modeli.
class Review {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}
