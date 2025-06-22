// ====================  User Profile Model ====================
class UserProfile {
  final String userId;
  final String email;
  final String name;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String activityLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phoneNumber;
  final DateTime? birthday;
  final String? imageUrl;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.birthday,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activityLevel': activityLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'birthday': birthday?.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      gender: map['gender'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      phoneNumber: map['phoneNumber'],
      birthday: DateTime.tryParse(map['birthday'] ?? ''),
      imageUrl: map['imageUrl'],
    );
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? name,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    DateTime? birthday,
    String? imageUrl,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthday: birthday ?? this.birthday,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // حساب السعرات الحرارية المطلوبة يومياً
  double get dailyCaloriesNeeded {
    // حساب BMR باستخدام معادلة Mifflin-St Jeor
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // ضرب BMR في معامل النشاط
    double activityMultiplier;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }

    return bmr * activityMultiplier;
  }
}

// ==================== Meal Model ====================

// ==================== Nutrition Data Model ====================

// ==================== Food Item Model ====================
class FoodItem {
  final String id;
  final String name;
  final String nameAr;
  final String category;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final double sodiumPer100g;
  final String? imageUrl;
  final bool isCommon;

  FoodItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    required this.fiberPer100g,
    required this.sugarPer100g,
    required this.sodiumPer100g,
    this.imageUrl,
    this.isCommon = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'category': category,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatsPer100g': fatsPer100g,
      'fiberPer100g': fiberPer100g,
      'sugarPer100g': sugarPer100g,
      'sodiumPer100g': sodiumPer100g,
      'imageUrl': imageUrl,
      'isCommon': isCommon,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameAr: map['nameAr'] ?? '',
      category: map['category'] ?? '',
      caloriesPer100g: map['caloriesPer100g']?.toDouble() ?? 0.0,
      proteinPer100g: map['proteinPer100g']?.toDouble() ?? 0.0,
      carbsPer100g: map['carbsPer100g']?.toDouble() ?? 0.0,
      fatsPer100g: map['fatsPer100g']?.toDouble() ?? 0.0,
      fiberPer100g: map['fiberPer100g']?.toDouble() ?? 0.0,
      sugarPer100g: map['sugarPer100g']?.toDouble() ?? 0.0,
      sodiumPer100g: map['sodiumPer100g']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'],
      isCommon: map['isCommon'] ?? false,
    );
  }

  // حساب القيم الغذائية لكمية معينة
  Map<String, double> getNutritionForAmount(double grams) {
    double factor = grams / 100;
    return {
      'calories': caloriesPer100g * factor,
      'protein': proteinPer100g * factor,
      'carbs': carbsPer100g * factor,
      'fats': fatsPer100g * factor,
      'fiber': fiberPer100g * factor,
      'sugar': sugarPer100g * factor,
      'sodium': sodiumPer100g * factor,
    };
  }
}

// ==================== Goal Model ====================
class Goal {
  final String id;
  final String userId;
  final String type; // weight_loss, weight_gain, maintain_weight, muscle_gain
  final double targetWeight;
  final DateTime targetDate;
  final double dailyCaloriesGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatsGoal;
  final int stepsGoal;
  final double waterGoal;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.type,
    required this.targetWeight,
    required this.targetDate,
    required this.dailyCaloriesGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatsGoal,
    required this.stepsGoal,
    required this.waterGoal,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'targetWeight': targetWeight,
      'targetDate': targetDate.toIso8601String(),
      'dailyCaloriesGoal': dailyCaloriesGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatsGoal': fatsGoal,
      'stepsGoal': stepsGoal,
      'waterGoal': waterGoal,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      targetWeight: map['targetWeight']?.toDouble() ?? 0.0,
      targetDate: DateTime.tryParse(map['targetDate'] ?? '') ?? DateTime.now(),
      dailyCaloriesGoal: map['dailyCaloriesGoal']?.toDouble() ?? 0.0,
      proteinGoal: map['proteinGoal']?.toDouble() ?? 0.0,
      carbsGoal: map['carbsGoal']?.toDouble() ?? 0.0,
      fatsGoal: map['fatsGoal']?.toDouble() ?? 0.0,
      stepsGoal: map['stepsGoal'] ?? 0,
      waterGoal: map['waterGoal']?.toDouble() ?? 0.0,
      isActive: map['isActive'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  // حساب التقدم نحو الهدف
  double getProgressPercentage(double currentWeight) {
    // هذا مثال بسيط، يمكن تطويره أكثر
    return ((currentWeight - targetWeight).abs() / targetWeight * 100)
        .clamp(0.0, 100.0);
  }
}

// ==================== Weekly Progress Model ====================
class WeeklyProgress {
  final String userId;
  final int year;
  final int weekNumber;
  final double averageWeight;
  final double totalCalories;
  final double averageCalories;
  final int totalSteps;
  final double totalWater;
  final DateTime weekStart;
  final DateTime weekEnd;
  final DateTime lastUpdated;

  WeeklyProgress({
    required this.userId,
    required this.year,
    required this.weekNumber,
    required this.averageWeight,
    required this.totalCalories,
    required this.averageCalories,
    required this.totalSteps,
    required this.totalWater,
    required this.weekStart,
    required this.weekEnd,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'year': year,
      'weekNumber': weekNumber,
      'averageWeight': averageWeight,
      'totalCalories': totalCalories,
      'averageCalories': averageCalories,
      'totalSteps': totalSteps,
      'totalWater': totalWater,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WeeklyProgress.fromMap(Map<String, dynamic> map) {
    return WeeklyProgress(
      userId: map['userId'] ?? '',
      year: map['year'] ?? 0,
      weekNumber: map['weekNumber'] ?? 0,
      averageWeight: map['averageWeight']?.toDouble() ?? 0.0,
      totalCalories: map['totalCalories']?.toDouble() ?? 0.0,
      averageCalories: map['averageCalories']?.toDouble() ?? 0.0,
      totalSteps: map['totalSteps'] ?? 0,
      totalWater: map['totalWater']?.toDouble() ?? 0.0,
      weekStart: DateTime.tryParse(map['weekStart'] ?? '') ?? DateTime.now(),
      weekEnd: DateTime.tryParse(map['weekEnd'] ?? '') ?? DateTime.now(),
      lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }
}