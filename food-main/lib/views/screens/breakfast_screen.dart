import 'package:flutter/material.dart';
import 'category_items_screen.dart';

class BreakfastScreen extends StatelessWidget {
  final List<Map<String, dynamic>> breakfastItems = [
    {
      'title': 'Cheese Plate',
      'price': '45.0',
      'time': '8',
      'image': 'assets/images/cheese.png',
      'description': 'Fresh and creamy cheese served with a selection of fresh herbs and olive oil.',
      'calories': '120',
      'rating': '4.7'
    },
    {
      'title': 'Fresh Croissant',
      'price': '35.0',
      'time': '8',
      'image': 'assets/images/croissant.png',
      'description': 'Freshly baked croissant filled with premium melted cheese.',
      'calories': '320',
      'rating': '4.8'
    },
    {
      'title': 'Healthy Mix',
      'price': '55.0',
      'time': '10',
      'image': 'assets/images/snacks.png',
      'description': 'A nutritious mix of fresh fruits, nuts, and yogurt.',
      'calories': '180',
      'rating': '4.9'
    },
    {
      'title': 'Eggs Benedict',
      'price': '65.0',
      'time': '15',
      'image': 'assets/images/egg.png',
      'description': 'Classic eggs Benedict with hollandaise sauce and smoked salmon.',
      'calories': '450',
      'rating': '4.9'
    },
    {
      'title': 'Rice Bowl',
      'price': '40.0',
      'time': '5',
      'image': 'assets/images/rice.png',
      'description': 'Fresh seasonal rice served with special sauce.',
      'calories': '150',
      'rating': '4.8'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryItemsScreen(
      title: 'Breakfast',
      items: breakfastItems,
    );
  }
}
