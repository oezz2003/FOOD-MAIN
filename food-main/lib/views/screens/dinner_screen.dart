import 'package:flutter/material.dart';
import 'category_items_screen.dart';

class DinnerScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dinnerItems = [
    {
      'title': 'Grilled Steak',
      'price': '250.0',
      'time': '35',
      'image': 'assets/images/steak.png',
      'description': 'Premium cut steak grilled to your preference with special sauce.',
      'calories': '650',
      'rating': '4.9'
    },
    {
      'title': 'Pasta Alfredo',
      'price': '180.0',
      'time': '25',
      'image': 'assets/images/rice.png',
      'description': 'Creamy pasta with grilled chicken and parmesan cheese.',
      'calories': '580',
      'rating': '4.8'
    },
    {
      'title': 'Pasta Alfredo',
      'price': '180.0',
      'time': '25',
      'image': 'assets/images/spageti.png',
      'description': 'Creamy pasta with grilled chicken and parmesan cheese.',
      'calories': '580',
      'rating': '4.8'
    },
    {
      'title': 'Seafood Mix',
      'price': '220.0',
      'time': '30',
      'image': 'assets/images/slices.png',
      'description': 'Fresh seafood mix with special herbs and lemon sauce.',
      'calories': '480',
      'rating': '4.9'
    },
    {
      'title': 'Grilled Salmon',
      'price': '210.0',
      'time': '25',
      'image': 'assets/images/quarter.png',
      'description': 'Fresh salmon fillet with herbs and vegetables.',
      'calories': '420',
      'rating': '4.8'
    },
    {
      'title': 'Mixed Grill',
      'price': '280.0',
      'time': '40',
      'image': 'assets/images/mushroom.png',
      'description': 'Assortment of grilled meats with special marinades.',
      'calories': '750',
      'rating': '4.9'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryItemsScreen(
      title: 'Dinner',
      items: dinnerItems,
    );
  }
}
