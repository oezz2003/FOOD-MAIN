import 'package:flutter/material.dart';
import 'food_details_screen.dart';

class CategoryItemsScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const CategoryItemsScreen({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  _CategoryItemsScreenState createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildGreeting(),
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final double delay = index * 0.2;
                        final double slideAnimation = Curves.easeOutCubic.transform(
                          ((_controller.value - delay) * 1.25).clamp(0.0, 1.0),
                        );
                        final double opacityAnimation = Curves.easeOut.transform(
                          ((_controller.value - delay) * 1.25).clamp(0.0, 1.0),
                        );

                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - slideAnimation)),
                          child: Opacity(
                            opacity: opacityAnimation,
                            child: _buildFoodItem(widget.items[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            getIconForCategory(widget.title),
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 15),
          Text(
            'Good ${getTimeOfDay()}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10),
          Icon(
            getTimeIcon(),
            color: Colors.amber,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailsScreen(
              title: item['title'],
              imagePath: item['image'],
              description: item['description'] ?? 'A delicious blend of fresh ingredients, expertly prepared to create a perfect harmony of flavors.',
              price: item['price'],
              time: item['time'],
              calories: item['calories'] ?? '350',
              rating: double.parse(item['rating'] ?? '4.5'),
              items: [],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.white70, size: 16),
                      SizedBox(width: 5),
                      Text(
                        '${item['time']} min',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${item['price']} LE',
                    style: TextStyle(
                      color: Colors.purple[100],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  item['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'coffee':
        return Icons.coffee;
      default:
        return Icons.restaurant;
    }
  }

  String getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  IconData getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny;
    if (hour < 17) return Icons.wb_sunny;
    return Icons.nights_stay;
  }
} 