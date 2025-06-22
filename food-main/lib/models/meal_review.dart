import 'package:cloud_firestore/cloud_firestore.dart';

class MealReview {
  final String id;
  final String mealId;
  final String userId;
  final String reviewText;
  final double rating;
  final DateTime createdAt;

  MealReview({
    required this.id,
    required this.mealId,
    required this.userId,
    required this.reviewText,
    required this.rating,
    required this.createdAt, required String comment, required String username,
  });

  factory MealReview.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MealReview(
      id: doc.id,
      mealId: data['mealId'] ?? '',
      userId: data['userId'] ?? '',
      reviewText: data['reviewText'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(), comment: '', username: '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mealId': mealId,
      'userId': userId,
      'reviewText': reviewText,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 