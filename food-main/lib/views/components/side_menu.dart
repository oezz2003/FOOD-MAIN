import 'package:flutter/material.dart';
import 'package:healthy_food/config/margin.dart';
import 'package:healthy_food/config/navigator.dart';
import 'package:healthy_food/views/screens/profile_screen.dart';
import '../screens/category_items_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9575CD),
              Color(0xFF7E57C2),
              Color(0xFF673AB7),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Healthy Food',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildMenuItem(
              context,
              'Breakfast',
              Icons.breakfast_dining,
              [
                {'title': 'Eggs Benedict', 'image': 'assets/images/breakfast/eggs_benedict.jpg', 'time': '20', 'price': '65'},
                {'title': 'Pancakes', 'image': 'assets/images/breakfast/pancakes.jpg', 'time': '15', 'price': '45'},
              ],
            ),
            _buildMenuItem(
              context,
              'Lunch',
              Icons.lunch_dining,
              [
                {'title': 'Grilled Chicken', 'image': 'assets/images/lunch/grilled_chicken.jpg', 'time': '30', 'price': '85'},
                {'title': 'Caesar Salad', 'image': 'assets/images/lunch/caesar_salad.jpg', 'time': '15', 'price': '55'},
              ],
            ),
            _buildMenuItem(
              context,
              'Dinner',
              Icons.dinner_dining,
              [
                {'title': 'Salmon Steak', 'image': 'assets/images/dinner/salmon.jpg', 'time': '25', 'price': '120'},
                {'title': 'Pasta Primavera', 'image': 'assets/images/dinner/pasta.jpg', 'time': '20', 'price': '75'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, List<Map<String, dynamic>> items) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryItemsScreen(
              title: title,
              items: items,
            ),
          ),
        );
      },
    );
  }
}
