import 'package:cloud_firestore/cloud_firestore.dart';

class UserGoals {
  final String userId;
  final double dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFats;
  final double dailyWater;
  final int dailySteps;
  final int dailyExerciseMinutes;
  final String goalType; // weight_loss, weight_gain, maintain
  final DateTime createdAt;
  final DateTime updatedAt;

  UserGoals({
    required this.userId,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFats,
    required this.dailyWater,
    required this.dailySteps,
    required this.dailyExerciseMinutes,
    required this.goalType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dailyCalories': dailyCalories,
      'dailyProtein': dailyProtein,
      'dailyCarbs': dailyCarbs,
      'dailyFats': dailyFats,
      'dailyWater': dailyWater,
      'dailySteps': dailySteps,
      'dailyExerciseMinutes': dailyExerciseMinutes,
      'goalType': goalType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserGoals.fromMap(Map<String, dynamic> map) {
    return UserGoals(
      userId: map['userId'] ?? '',
      dailyCalories: map['dailyCalories']?.toDouble() ?? 0.0,
      dailyProtein: map['dailyProtein']?.toDouble() ?? 0.0,
      dailyCarbs: map['dailyCarbs']?.toDouble() ?? 0.0,
      dailyFats: map['dailyFats']?.toDouble() ?? 0.0,
      dailyWater: map['dailyWater']?.toDouble() ?? 0.0,
      dailySteps: map['dailySteps']?.toInt() ?? 0,
      dailyExerciseMinutes: map['dailyExerciseMinutes']?.toInt() ?? 0,
      goalType: map['goalType'] ?? 'maintain',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  UserGoals copyWith({
    String? userId,
    double? dailyCalories,
    double? dailyProtein,
    double? dailyCarbs,
    double? dailyFats,
    double? dailyWater,
    int? dailySteps,
    int? dailyExerciseMinutes,
    String? goalType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserGoals(
      userId: userId ?? this.userId,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProtein: dailyProtein ?? this.dailyProtein,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      dailyFats: dailyFats ?? this.dailyFats,
      dailyWater: dailyWater ?? this.dailyWater,
      dailySteps: dailySteps ?? this.dailySteps,
      dailyExerciseMinutes: dailyExerciseMinutes ?? this.dailyExerciseMinutes,
      goalType: goalType ?? this.goalType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}