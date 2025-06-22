import 'package:cloud_firestore/cloud_firestore.dart';

class MealHistory {
  final String id;
  final String userId;
  final String mealName;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final DateTime dateTime;
  final String mealType; // breakfast, lunch, dinner, snack
  final String? imageUrl;

  MealHistory({
    required this.id,
    required this.userId,
    required this.mealName,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.dateTime,
    required this.mealType,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mealName': mealName,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'dateTime': Timestamp.fromDate(dateTime),
      'mealType': mealType,
      'imageUrl': imageUrl,
    };
  }

  factory MealHistory.fromMap(Map<String, dynamic> map) {
    return MealHistory(
      id: map['id'],
      userId: map['userId'],
      mealName: map['mealName'],
      calories: map['calories']?.toDouble() ?? 0.0,
      proteins: map['proteins']?.toDouble() ?? 0.0,
      carbs: map['carbs']?.toDouble() ?? 0.0,
      fats: map['fats']?.toDouble() ?? 0.0,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      mealType: map['mealType'],
      imageUrl: map['imageUrl'],
    );
  }
} 