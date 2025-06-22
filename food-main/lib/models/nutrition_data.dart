import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NutritionData {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double water; // بالليتر
  final double steps; // خطوات
  final double waterIntake; // كمية الماء المتناولة
  final List<MealEntry> meals;
  final String? notes;

  NutritionData({
    required this.date,
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.water = 0.0,
    this.steps = 0.0,
    this.waterIntake = 0.0,
    this.meals = const [],
    this.notes,
  });

  // تحويل إلى Map للحفظ في Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'water': water,
      'steps': steps,
      'waterIntake': waterIntake,
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'notes': notes,
    };
  }

  // إنشاء من Map (من Firestore) - الإصلاح هنا
  factory NutritionData.fromMap(Map<String, dynamic> map) {
    return NutritionData(
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      calories: (map['calories'] ?? 0.0).toDouble(),
      protein: (map['protein'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      fiber: (map['fiber'] ?? 0.0).toDouble(),
      sugar: (map['sugar'] ?? 0.0).toDouble(),
      sodium: (map['sodium'] ?? 0.0).toDouble(),
      water: (map['water'] ?? 0.0).toDouble(),
      steps: (map['steps'] ?? 0.0).toDouble(),
      waterIntake: (map['waterIntake'] ?? 0.0).toDouble(),
      meals: _parseMealsList(map['meals']),
      notes: map['notes'],
    );
  }

  // دالة مساعدة لتحليل قائمة الوجبات بشكل آمن
  static List<MealEntry> _parseMealsList(dynamic mealsData) {
    if (mealsData == null) return [];
    
    if (mealsData is List) {
      return mealsData
          .where((meal) => meal is Map<String, dynamic>)
          .map((meal) => MealEntry.fromMap(meal as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  // إنشاء نسخة معدلة
  NutritionData copyWith({
    DateTime? date,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    double? water,
    double? steps,
    double? waterIntake,
    List<MealEntry>? meals,
    String? notes,
  }) {
    return NutritionData(
      date: date ?? this.date,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      water: water ?? this.water,
      steps: steps ?? this.steps,
      waterIntake: waterIntake ?? this.waterIntake,
      meals: meals ?? this.meals,
      notes: notes ?? this.notes,
    );
  }

  // إضافة وجبة جديدة
  NutritionData addMeal(MealEntry meal) {
    final updatedMeals = List<MealEntry>.from(meals)..add(meal);
    return copyWith(
      meals: updatedMeals,
      calories: calories + meal.calories,
      protein: protein + meal.protein,
      carbs: carbs + meal.carbs,
      fat: fat + meal.fat,
      fiber: fiber + meal.fiber,
      sugar: sugar + meal.sugar,
      sodium: sodium + meal.sodium,
    );
  }

  // حذف وجبة
  NutritionData removeMeal(int index) {
    if (index < 0 || index >= meals.length) return this;
    
    final mealToRemove = meals[index];
    final updatedMeals = List<MealEntry>.from(meals)..removeAt(index);
    
    return copyWith(
      meals: updatedMeals,
      calories: _safeSubtraction(calories, mealToRemove.calories),
      protein: _safeSubtraction(protein, mealToRemove.protein),
      carbs: _safeSubtraction(carbs, mealToRemove.carbs),
      fat: _safeSubtraction(fat, mealToRemove.fat),
      fiber: _safeSubtraction(fiber, mealToRemove.fiber),
      sugar: _safeSubtraction(sugar, mealToRemove.sugar),
      sodium: _safeSubtraction(sodium, mealToRemove.sodium),
    );
  }

  // دالة مساعدة للطرح الآمن (لتجنب القيم السالبة)
  double _safeSubtraction(double original, double subtract) {
    final result = original - subtract;
    return result < 0 ? 0.0 : result;
  }

  // تحديث وجبة موجودة
  NutritionData updateMeal(int index, MealEntry newMeal) {
    if (index < 0 || index >= meals.length) return this;
    
    final oldMeal = meals[index];
    final updatedMeals = List<MealEntry>.from(meals);
    updatedMeals[index] = newMeal;
    
    return copyWith(
      meals: updatedMeals,
      calories: calories - oldMeal.calories + newMeal.calories,
      protein: protein - oldMeal.protein + newMeal.protein,
      carbs: carbs - oldMeal.carbs + newMeal.carbs,
      fat: fat - oldMeal.fat + newMeal.fat,
      fiber: fiber - oldMeal.fiber + newMeal.fiber,
      sugar: sugar - oldMeal.sugar + newMeal.sugar,
      sodium: sodium - oldMeal.sodium + newMeal.sodium,
    );
  }

  // الحصول على الوجبات حسب النوع
  List<MealEntry> getMealsByType(MealType type) {
    return meals.where((meal) => meal.type == type).toList();
  }

  // الحصول على مجموع السعرات لنوع وجبة معين
  double getCaloriesByMealType(MealType type) {
    return getMealsByType(type).fold(0.0, (sum, meal) => sum + meal.calories);
  }

  @override
  String toString() {
    return 'NutritionData(date: $date, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, meals: ${meals.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NutritionData &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day &&
        other.calories == calories &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fat == fat;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        calories.hashCode ^
        protein.hashCode ^
        carbs.hashCode ^
        fat.hashCode;
  }
}

class MealEntry {
  final String id;
  final String name;
  final MealType type;
  final double quantity; // بالجرام أو الكوب
  final String unit; // جرام، كوب، ملعقة، إلخ
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final String? imageUrl;
  final DateTime timestamp;

  MealEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    this.unit = 'جرام',
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.imageUrl,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: MealType.values.firstWhere(
          (e) => e.name == (map['type'] ?? MealType.other.name)),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'جرام',
      calories: (map['calories'] ?? 0.0).toDouble(),
      protein: (map['protein'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      fiber: (map['fiber'] ?? 0.0).toDouble(),
      sugar: (map['sugar'] ?? 0.0).toDouble(),
      sodium: (map['sodium'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  other,
}

class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = ''; // يجب تحديد معرف المستخدم

  // تحديد معرف المستخدم
  void setUserId(String id) {
    userId = id;
  }

  // الحصول على البيانات الغذائية لتاريخ معين - الإصلاح الصحيح هنا
  Future<NutritionData?> getNutritionData(DateTime date) async {
    try {
      if (userId.isEmpty) return null;

      DocumentSnapshot doc = await _firestore
          .collection('nutrition_data')
          .doc(userId)
          .collection('daily')
          .doc(date.toIso8601String().split('T')[0])
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          return NutritionData.fromMap(data);
        } else {
          print('Document data is not in expected format: ${data.runtimeType}');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error getting nutrition data: $e');
      rethrow;
    }
  }

  // إضافة البيانات الغذائية
  Future<void> addNutritionData(NutritionData data) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }

      final dateKey = data.date.toIso8601String().split('T')[0];

      await _firestore
          .collection('nutrition_data')
          .doc(userId)
          .collection('daily')
          .doc(dateKey)
          .set(data.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      print('Firebase Error adding nutrition data: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding nutrition data: $e');
      rethrow;
    }
  }

  // الحصول على التقدم الأسبوعي
  Future<List<NutritionData>> getWeeklyProgress(DateTime weekStart) async {
    try {
      if (userId.isEmpty) return [];

      final weekEnd = weekStart.add(Duration(days: 6));
      final weekStartStr = weekStart.toIso8601String().split('T')[0];
      final weekEndStr = weekEnd.toIso8601String().split('T')[0];

      QuerySnapshot querySnapshot = await _firestore
          .collection('nutrition_data')
          .doc(userId)
          .collection('daily')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: weekStartStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: weekEndStr)
          .get();

      List<NutritionData> weeklyData = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            weeklyData.add(NutritionData.fromMap(data));
          }
        }
      }

      return weeklyData;
    } catch (e) {
      print('Error getting weekly progress: $e');
      rethrow;
    }
  }

  // رفع الصور
  Future<String?> uploadImage(String imagePath) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('nutrition_images')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putFile(File(imagePath));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Error uploading image: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // حذف البيانات الغذائية لتاريخ معين
  Future<void> deleteNutritionData(DateTime date) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }

      final dateKey = date.toIso8601String().split('T')[0];

      await _firestore
          .collection('nutrition_data')
          .doc(userId)
          .collection('daily')
          .doc(dateKey)
          .delete();
    } catch (e) {
      print('Error deleting nutrition data: $e');
      rethrow;
    }
  }

  // الحصول على بيانات شهر كامل
  Future<List<NutritionData>> getMonthlyProgress(DateTime monthDate) async {
    try {
      if (userId.isEmpty) return [];

      final monthStart = DateTime(monthDate.year, monthDate.month, 1);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0);
      
      final monthStartStr = monthStart.toIso8601String().split('T')[0];
      final monthEndStr = monthEnd.toIso8601String().split('T')[0];

      QuerySnapshot querySnapshot = await _firestore
          .collection('nutrition_data')
          .doc(userId)
          .collection('daily')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: monthStartStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: monthEndStr)
          .orderBy(FieldPath.documentId)
          .get();

      List<NutritionData> monthlyData = [];

      for (var doc in querySnapshot.docs) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            monthlyData.add(NutritionData.fromMap(data));
          }
        }
      }

      return monthlyData;
    } catch (e) {
      print('Error getting monthly progress: $e');
      rethrow;
    }
  }

  // البحث عن الأطعمة
  Stream<List<NutritionData>> searchNutritionData(String searchTerm) {
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('nutrition_data')
        .doc(userId)
        .collection('daily')
        .snapshots()
        .map((snapshot) {
      List<NutritionData> results = [];
      
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            final nutritionData = NutritionData.fromMap(data);
            
            // البحث في أسماء الوجبات
            final hasMatchingMeal = nutritionData.meals.any((meal) =>
                meal.name.toLowerCase().contains(searchTerm.toLowerCase()));
            
            if (hasMatchingMeal) {
              results.add(nutritionData);
            }
          }
        }
      }
      
      return results;
    });
  }
}

// مثال على كيفية الاستخدام
class NutritionExample {
  final NutritionService _service = NutritionService();

  // تهيئة الخدمة
  void initialize(String userId) {
    _service.setUserId(userId);
  }

  // إضافة وجبة جديدة
  Future<void> addMealExample() async {
    try {
      // إنشاء وجبة جديدة
      final meal = MealEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'بيض مسلوق',
        type: MealType.breakfast,
        quantity: 100,
        unit: 'جرام',
        calories: 155,
        protein: 13,
        carbs: 1.1,
        fat: 11,
        fiber: 0,
        sugar: 1.1,
        sodium: 124,
      );

      // الحصول على البيانات الحالية للتاريخ
      final today = DateTime.now();
      NutritionData? currentData = await _service.getNutritionData(today);

      if (currentData == null) {
        // إنشاء بيانات جديدة
        currentData = NutritionData(date: today);
      }

      // إضافة الوجبة للبيانات
      final updatedData = currentData.addMeal(meal);

      // حفظ البيانات
      await _service.addNutritionData(updatedData);

      print('تم إضافة الوجبة بنجاح');
    } catch (e) {
      print('خطأ في إضافة الوجبة: $e');
    }
  }

  // الحصول على البيانات اليومية
  Future<void> getTodayDataExample() async {
    try {
      final today = DateTime.now();
      final data = await _service.getNutritionData(today);

      if (data != null) {
        print('السعرات الحرارية اليوم: ${data.calories}');
        print('البروتين: ${data.protein}g');
        print('الكربوهيدرات: ${data.carbs}g');
        print('الدهون: ${data.fat}g');
        print('عدد الوجبات: ${data.meals.length}');
      } else {
        print('لا توجد بيانات لهذا اليوم');
      }
    } catch (e) {
      print('خطأ في الحصول على البيانات: $e');
    }
  }
}
 