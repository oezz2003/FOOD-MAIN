import 'package:flutter/material.dart';
import 'package:healthy_food/models/meal.dart';
import 'package:healthy_food/models/nutrition_data.dart' show NutritionData;
import 'package:healthy_food/services/firebase_service.dart';

class MealProvider extends ChangeNotifier {
  List<Meal> _meals = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  List<Meal> get meals => _meals;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  MealProvider() {
    _initializeProvider();
  }

  void _initializeProvider() {
    // الاستماع لتغييرات البيانات من Firebase
    FirebaseService.getMealsStream().listen((meals) {
      _meals = meals;
      notifyListeners();
    });
  }

  // تحديد التاريخ المختار
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // جلب الوجبات حسب النوع والتاريخ
  List<Meal> getMealsByType(MealType mealType, DateTime date) {
    String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    
    return _meals.where((meal) => 
      meal.type == mealType && 
      meal.date == dateString
    ).toList();
  }

  // جلب جميع الوجبات لتاريخ محدد
  List<Meal> getMealsByDate(DateTime date) {
    String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    
    return _meals.where((meal) => meal.date == dateString).toList();
  }

  // حساب إجمالي السعرات لتاريخ ونوع وجبة محددين
  double getTotalCalories(MealType mealType, DateTime date) {
    List<Meal> meals = getMealsByType(mealType, date);
    return meals.fold(0.0, (sum, meal) => sum + meal.calories);
  }

  // حساب إجمالي السعرات ليوم كامل
  double getDayTotalCalories(DateTime date) {
    List<Meal> dayMeals = getMealsByDate(date);
    return dayMeals.fold(0.0, (sum, meal) => sum + meal.calories);
  }

  // حساب إجمالي البروتينات ليوم كامل
  double getDayTotalProteins(DateTime date) {
    List<Meal> dayMeals = getMealsByDate(date);
    return dayMeals.fold(0.0, (sum, meal) => sum + meal.proteins);
  }

  // حساب إجمالي الكربوهيدرات ليوم كامل
  double getDayTotalCarbs(DateTime date) {
    List<Meal> dayMeals = getMealsByDate(date);
    return dayMeals.fold(0.0, (sum, meal) => sum + meal.carbs);
  }

  // حساب إجمالي الدهون ليوم كامل
  double getDayTotalFats(DateTime date) {
    List<Meal> dayMeals = getMealsByDate(date);
    return dayMeals.fold(0.0, (sum, meal) => sum + meal.fats);
  }

  // إضافة وجبة جديدة
  Future<void> addMeal(Meal meal) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firebaseService.addMeal(meal);
      // البيانات ستتحدث تلقائياً من خلال Stream
    } catch (e) {
      print('Error adding meal: $e');
      // يمكنك إضافة معالجة للأخطاء هنا
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // حذف وجبة
  Future<void> removeMeal(String mealId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // البحث عن الوجبة لإيجاد تاريخها
      final mealToRemove = _meals.firstWhere((meal) => meal.id == mealId, orElse: () => throw Exception('Meal not found'));
      await _firebaseService.deleteMeal(mealId, mealToRemove.date as String);
      // البيانات ستتحدث تلقائياً من خلال Stream
    } catch (e) {
      print('Error removing meal: $e');
      // يمكنك إضافة معالجة للأخطاء هنا
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث وجبة موجودة
  Future<void> updateMeal(Meal meal) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // حذف الوجبة القديمة وإضافة الجديدة
      await _firebaseService.deleteMeal(meal.id, meal.date as String);
      await _firebaseService.addMeal(meal);
    } catch (e) {
      print('Error updating meal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إحصائيات للأسبوع الحالي
  Map<String, double> getWeeklyStats(DateTime startOfWeek) {
    Map<String, double> stats = {
      'totalCalories': 0,
      'totalProteins': 0,
      'totalCarbs': 0,
      'totalFats': 0,
    };

    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      stats['totalCalories'] = stats['totalCalories']! + getDayTotalCalories(day);
      stats['totalProteins'] = stats['totalProteins']! + getDayTotalProteins(day);
      stats['totalCarbs'] = stats['totalCarbs']! + getDayTotalCarbs(day);
      stats['totalFats'] = stats['totalFats']! + getDayTotalFats(day);
    }

    return stats;
  }

  // جلب ملخص البيانات الغذائية ليوم معين
 
    }
  