import 'package:flutter/material.dart';
import 'category_items_screen.dart';

class LunchScreen extends StatelessWidget {
  final List<Map<String, dynamic>> lunchItems = [
    {
      'title': 'Grilled Chicken',
      'price': '120.0',
      'time': '25',
      'image': 'assets/images/chicken.png',
      'description': 'Marinated grilled chicken with herbs and vegetables.',
      'calories': '450',
      'rating': '4.8'
    },
    {
      'title': 'Special Pizza',
      'price': '140.0',
      'time': '30',
      'image': 'assets/images/pizza.png',
      'description': 'Fresh pizza with special toppings and cheese.',
      'calories': '550',
      'rating': '4.9'
    },
    {
      'title': 'French Fries',
      'price': '45.0',
      'time': '15',
      'image': 'assets/images/fries.png',
      'description': 'Crispy french fries with special seasoning.',
      'calories': '320',
      'rating': '4.7'
    },
    {
      'title': 'Spaghetti',
      'price': '110.0',
      'time': '20',
      'image': 'assets/images/spageti.png',
      'description': 'Classic spaghetti with rich sauce and parmesan.',
      'calories': '480',
      'rating': '4.8'
    },
    {
      'title': 'Quarter Meal',
      'price': '160.0',
      'time': '25',
      'image': 'assets/images/quarter.png',
      'description': 'Special quarter meal with sides.',
      'calories': '580',
      'rating': '4.9'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryItemsScreen(
      title: 'Lunch',
      items: lunchItems,
    );
  }
}
