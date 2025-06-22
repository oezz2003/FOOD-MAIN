import 'package:flutter/material.dart';
import 'package:healthy_food/views/screens/splash_screen.dart';
import 'package:healthy_food/views/screens/auth_screen.dart';
import 'package:healthy_food/views/screens/home_screen.dart';
import 'package:healthy_food/views/screens/meals_screen.dart';
import 'package:healthy_food/views/screens/meal_category_screen.dart';
import 'package:healthy_food/views/screens/profile_screen.dart';
import 'package:healthy_food/views/screens/plan_screen.dart';
import 'package:healthy_food/views/screens/order_summary_screen.dart'; // ✅ استيراد شاشة ملخص الطلب
import 'package:healthy_food/models/menu_screen.dart';
import 'package:healthy_food/models/meal.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String meals = '/meals';
  static const String breakfast = '/breakfast';
  static const String lunch = '/lunch';
  static const String dinner = '/dinner';
  static const String snacks = '/snacks';
  static const String profile = '/profile';
  static const String plan = '/plan';
  static const String orderSummary = '/orderSummary';
  static const String settings = '/settings';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case auth:
        return MaterialPageRoute(builder: (_) => AuthScreen());

      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case meals:
        return MaterialPageRoute(builder: (_) => MenuScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());

      case plan:
        return MaterialPageRoute(builder: (_) => PlanScreen());

      case breakfast:
        return MaterialPageRoute(
          builder: (_) => MealCategoryScreen(
            mealType: MealType.breakfast,
            title: 'Breakfast',
          ),
        );

      case lunch:
        return MaterialPageRoute(
          builder: (_) => MealCategoryScreen(
            mealType: MealType.lunch,
            title: 'Lunch',
          ),
        );

      case dinner:
        return MaterialPageRoute(
          builder: (_) => MealCategoryScreen(
            mealType: MealType.dinner,
            title: 'Dinner',
          ),
        );

      case snacks:
        return MaterialPageRoute(
          builder: (_) => MealCategoryScreen(
            mealType: MealType.snacks,
            title: 'Snacks',
          ),
        );

      case orderSummary: // ✅ التعامل مع المسار الجديد
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => OrderSummaryScreen(
           // orderId: args?['orderId'] ?? '',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}
