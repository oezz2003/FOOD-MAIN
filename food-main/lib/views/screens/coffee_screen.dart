import 'package:flutter/material.dart';
import 'category_items_screen.dart';

class CoffeeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> coffeeItems = [
    {
      'title': 'Espresso',
      'price': '35.0',
      'time': '5',
      'image': 'assets/images/espreso.png',
      'description': 'Rich and intense espresso shot made from premium coffee beans.',
      'calories': '5',
      'rating': '4.9'
    },
    {
      'title': 'Cappuccino',
      'price': '45.0',
      'time': '8',
      'image': 'assets/images/milk.png',
      'description': 'Classic Italian coffee with perfectly steamed milk foam.',
      'calories': '120',
      'rating': '4.8'
    },
    {
      'title': 'Latte',
      'price': '50.0',
      'time': '8',
      'image': 'assets/images/milk.png',
      'description': 'Smooth coffee with steamed milk and light foam.',
      'calories': '150',
      'rating': '4.8'
    },
    {
      'title': 'Mocha',
      'price': '55.0',
      'time': '10',
      'image': 'assets/images/caribe.png',
      'description': 'Perfect blend of coffee, chocolate, and steamed milk.',
      'calories': '200',
      'rating': '4.7'
    },
    {
      'title': 'Iced Coffee',
      'price': '40.0',
      'time': '5',
      'image': 'assets/images/mon.png',
      'description': 'Chilled coffee served with ice and cream.',
      'calories': '180',
      'rating': '4.8'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryItemsScreen(
      title: 'Coffee',
      items: coffeeItems,
    );
  }
}
