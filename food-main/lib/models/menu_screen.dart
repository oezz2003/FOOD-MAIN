import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:healthy_food/views/screens/detail_screen.dart';
import 'package:healthy_food/views/screens/home_screen.dart';
import 'package:healthy_food/views/screens/profile_screen.dart';
import 'package:healthy_food/views/screens/cart_screen.dart';
import 'package:healthy_food/models/meal_plan.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'breakfast';
  late AnimationController _animationController;
  int _selectedIndex = 1;
  Map<String, int>? userGoals = {
    'dailyCalories': 2000,
    'dailyProtein': 150,
    'dailyCarbs': 250,
    'dailyFats': 65,
  };

  List<Map<String, dynamic>> selectedMeals = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildCategorySelector(),
            Expanded(child: _buildMenuList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: selectedMeals.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.summarize, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Meal Plan Summary'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📊 General Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Number of meals: ${selectedMeals.length}'),
                        Text('Total calories: ${getTotalCalories()} cal'),
                        Text('Total protein: ${getTotalProtein()} g'),
                        Text('Total carbs: ${getTotalCarbs()} g'),
                        Text('Total fats: ${getTotalFats()} g'),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🎯 Comparison with Goals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        _buildSummaryProgress('Calories', getTotalCalories(), userGoals?['dailyCalories'] ?? 2000),
                        _buildSummaryProgress('Protein', getTotalProtein(), userGoals?['dailyProtein'] ?? 150),
                        _buildSummaryProgress('Carbs', getTotalCarbs(), userGoals?['dailyCarbs'] ?? 250),
                        _buildSummaryProgress('Fats', getTotalFats(), userGoals?['dailyFats'] ?? 65),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _saveMealPlan();
                  },
                  icon: Icon(Icons.save),
                  label: Text('Save Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.save),
        label: Text('Save Plan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      )
          : null,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[800]),
            onPressed: Navigator.of(context).pop,
          ),
          Text(
            'Food Menu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[800]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'name': 'Breakfast', 'key': 'breakfast', 'color': Colors.green},
      {'name': 'Lunch', 'key': 'lunch', 'color': Colors.blue},
      {'name': 'Dinner', 'key': 'dinner', 'color': Colors.purple},
      {'name': 'Snacks', 'key': 'snack', 'color': Colors.orange},
    ];
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['key'];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['key']! as String;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? category['color'] as Color : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  category['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('menuItems').where('category', isEqualTo: selectedCategory).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final double delay = index * 0.1;
                final curvedAnimation = CurvedAnimation(
                    parent: _animationController, curve: Interval(delay, 1.0, curve: Curves.easeOut));
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                        .animate(curvedAnimation),
                    child: _buildMenuItem(data, index),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, int index) {
    final name = item['name'] ?? 'Unknown Item';
    final description = item['description'] ?? '';
    final image = item['image'] ?? '';
    final price = item['price']?.toDouble() ?? 0.0;
    final calories = item['calories']?.toInt() ?? 0;
    final protein = item['protein']?.toInt() ?? 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(menuItem: item, heroTag: 'item_$index'),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'item_$index',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    placeholder: (context, url) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.fastfood, size: 40, color: Colors.grey[400]),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text('\$$price'),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: TextStyle(color: Colors.green.shade800),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          description,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (calories > 0)
                          _buildInfoChip(Icons.local_fire_department, '$calories cal', Colors.orange),
                        if (protein > 0)
                          _buildInfoChip(Icons.fitness_center, '$protein g protein', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(label),
      labelStyle: TextStyle(color: color, fontSize: 12),
      backgroundColor: color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green.shade600),
          const SizedBox(height: 16),
          const Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 50),
            const SizedBox(height: 16),
            Text('An error occurred: $error', textAlign: TextAlign.center),
            ElevatedButton.icon(
              onPressed: _addSampleData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload or Add Sample Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No items in this category'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addSampleData,
              icon: const Icon(Icons.add),
              label: const Text('Add Sample Data'),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (index == 1) {
      // You are already in the menu
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MealPlanScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CartScreen()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.green : Colors.grey),
            onPressed: () => _onNavBarTap(0),
            tooltip: 'Home',
          ),
          IconButton(
            icon: Icon(Icons.restaurant_menu, color: _selectedIndex == 1 ? Colors.green : Colors.grey),
            onPressed: () => _onNavBarTap(1),
            tooltip: 'Menu',
          ),
          IconButton(
            icon: Icon(Icons.fastfood, color: _selectedIndex == 2 ? Colors.green : Colors.grey),
            onPressed: () => _onNavBarTap(2),
            tooltip: 'Meal Plan',
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: _selectedIndex == 3 ? Colors.green : Colors.grey),
            onPressed: () => _onNavBarTap(3),
            tooltip: 'Cart',
          ),
          IconButton(
            icon: Icon(Icons.person, color: _selectedIndex == 4 ? Colors.green : Colors.grey),
            onPressed: () => _onNavBarTap(4),
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  void _addToCart(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Unknown Item';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Added $name to cart'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addSampleData() async {
    final sampleData = [
      // ✅ Breakfast (10 items)
      {
        "name": "Scrambled Eggs with Cheese",
        "description": "Fresh eggs scrambled with white cheese and vegetables",
        "price": 25.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=500",
        "calories": 320,
        "protein": 18,
        "isAvailable": true
      },
      {
        "name": "Salmon Breakfast",
        "description": "Grilled salmon with scrambled eggs and toast",
        "price": 40.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500",
        "calories": 410,
        "protein": 25,
        "isAvailable": true
      },
      {
        "name": "Cheese Borek",
        "description": "Pastry filled with fresh cheese",
        "price": 20.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500",
        "calories": 290,
        "protein": 12,
        "isAvailable": true
      },
      {
        "name": "Date Pancakes",
        "description": "Small pancakes filled with dates and butter",
        "price": 18.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=500",
        "calories": 260,
        "protein": 6,
        "isAvailable": true
      },
      {
        "name": "Toast with Jam",
        "description": "Toasted bread with butter and natural jam",
        "price": 15.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=500",
        "calories": 220,
        "protein": 5,
        "isAvailable": true
      },
      {
        "name": "Eggs with Spinach",
        "description": "Scrambled eggs with spinach and mushrooms",
        "price": 28.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1551218808-94e220e084d2?w=500",
        "calories": 300,
        "protein": 16,
        "isAvailable": true
      },
      {
        "name": "Halloumi with Eggs",
        "description": "Fried eggs with halloumi cheese and yogurt",
        "price": 30.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1508737804141-4c3b688e2546?w=500",
        "calories": 340,
        "protein": 20,
        "isAvailable": true
      },
      {
        "name": "Fava Beans",
        "description": "Boiled fava beans with olive oil and garlic",
        "price": 12.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1596797038530-2c107229654b?w=500",
        "calories": 270,
        "protein": 13,
        "isAvailable": true
      },
      {
        "name": "Breakfast Pizza",
        "description": "Pizza with eggs, cheese, and sausages",
        "price": 35.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500",
        "calories": 400,
        "protein": 22,
        "isAvailable": true
      },
      {
        "name": "Oatmeal with Milk and Fruits",
        "description": "Cooked oatmeal with milk and fresh fruits",
        "price": 20.0,
        "category": "breakfast",
        "image": "https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=500",
        "calories": 280,
        "protein": 10,
        "isAvailable": true
      },

      // ✅ Lunch (10 items)
      {
        "name": "Chicken Burger",
        "description": "Grilled chicken burger with fresh vegetables",
        "price": 45.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500",
        "calories": 520,
        "protein": 28,
        "isAvailable": true
      },
      {
        "name": "Chicken Shawarma",
        "description": "Grilled chicken strips with vegetables and bread",
        "price": 40.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500",
        "calories": 500,
        "protein": 25,
        "isAvailable": true
      },
      {
        "name": "Grilled Chicken",
        "description": "Grilled chicken breast with rice and vegetables",
        "price": 55.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500",
        "calories": 580,
        "protein": 35,
        "isAvailable": true
      },
      {
        "name": "Chicken Pasta",
        "description": "Pasta with creamy chicken sauce",
        "price": 50.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1621996346565-e3dbc353d946?w=500",
        "calories": 600,
        "protein": 28,
        "isAvailable": true
      },
      {
        "name": "Spiced Crab",
        "description": "Spiced crab with rice and potatoes",
        "price": 70.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1559737558-2cc5579de5ad?w=500",
        "calories": 650,
        "protein": 40,
        "isAvailable": true
      },
      {
        "name": "Grilled Kibbeh",
        "description": "Grilled kibbeh with salad and vegetables",
        "price": 45.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1578662996442-48f60104821a?w=500",
        "calories": 520,
        "protein": 22,
        "isAvailable": true
      },
      {
        "name": "Chicken Soup",
        "description": "Rich chicken soup with vegetables",
        "price": 35.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=500",
        "calories": 320,
        "protein": 18,
        "isAvailable": true
      },
      {
        "name": "Grilled Salmon",
        "description": "Grilled salmon with rice and vegetables",
        "price": 80.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500",
        "calories": 700,
        "protein": 45,
        "isAvailable": true
      },
      {
        "name": "Meat Kabsa",
        "description": "Rice cooked with grilled meat pieces",
        "price": 60.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=500",
        "calories": 680,
        "protein": 38,
        "isAvailable": true
      },
      {
        "name": "Tuna Sandwich",
        "description": "Tuna sandwich with mayonnaise and vegetables",
        "price": 30.0,
        "category": "lunch",
        "image": "https://images.unsplash.com/photo-1509722747041-616f39b57569?w=500",
        "calories": 400,
        "protein": 20,
        "isAvailable": true
      },

      // ✅ Dinner (10 items)
      {
        "name": "Mixed Grills",
        "description": "Mix of grilled meats with vegetables",
        "price": 85.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=500",
        "calories": 750,
        "protein": 50,
        "isAvailable": true
      },
      {
        "name": "Grilled Fish",
        "description": "Grilled white fish with potatoes and salad",
        "price": 90.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1535140728325-781d5efef088?w=500",
        "calories": 680,
        "protein": 45,
        "isAvailable": true
      },
      {
        "name": "Oven-Baked Chicken",
        "description": "Roasted chicken with spices and grilled vegetables",
        "price": 65.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=500",
        "calories": 620,
        "protein": 40,
        "isAvailable": true
      },
      {
        "name": "Meatballs with Sauce",
        "description": "Meatballs with tomato sauce and rice",
        "price": 55.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1574484284002-952d92456975?w=500",
        "calories": 580,
        "protein": 35,
        "isAvailable": true
      },
      {
        "name": "Eggplant with Meat",
        "description": "Eggplant stuffed with minced meat",
        "price": 50.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1565299585323-38174c678d9d?w=500",
        "calories": 520,
        "protein": 28,
        "isAvailable": true
      },
      {
        "name": "Grilled Shrimp",
        "description": "Fresh grilled shrimp with vegetables",
        "price": 95.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500",
        "calories": 700,
        "protein": 55,
        "isAvailable": true
      },
      {
        "name": "Chicken Fajitas",
        "description": "Chicken with peppers and cumin in hot pan",
        "price": 60.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1545093149-618ce3bcf49d?w=500",
        "calories": 600,
        "protein": 35,
        "isAvailable": true
      },
      {
        "name": "Carbonara Pasta",
        "description": "Pasta with creamy sauce and bacon",
        "price": 55.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1551183053-inspired-1b33d4c9f5a7?w=500",
        "calories": 650,
        "protein": 25,
        "isAvailable": true
      },
      {
        "name": "Falafel with Bread",
        "description": "Falafel with vegetables and pita bread",
        "price": 35.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1589165609521-c7a5c9dc6b9d?w=500",
        "calories": 450,
        "protein": 18,
        "isAvailable": true
      },
      {
        "name": "Chicken with Thyme",
        "description": "Grilled chicken breast with thyme and olive oil",
        "price": 60.0,
        "category": "dinner",
        "image": "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500",
        "calories": 580,
        "protein": 38,
        "isAvailable": true
      },

      // ✅ Snack (10 items)
      {
        "name": "Cheese Popcorn",
        "description": "Fried corn kernels with melted cheese",
        "price": 15.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1578662996442-48f12f9048b1?w=500",
        "calories": 300,
        "protein": 8,
        "isAvailable": true
      },
      {
        "name": "Cheese Chips",
        "description": "Chips with grated cheese and spice mix",
        "price": 20.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1613919113640-25732ec5e61f?w=500",
        "calories": 280,
        "protein": 10,
        "isAvailable": true
      },
      {
        "name": "French Fries",
        "description": "Crispy potato slices",
        "price": 18.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1576107232684-1279f390859d?w=500",
        "calories": 320,
        "protein": 4,
        "isAvailable": true
      },
      {
        "name": "Yogurt-Flavored Chips",
        "description": "Traditional chips with yogurt flavor",
        "price": 12.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=500",
        "calories": 250,
        "protein": 6,
        "isAvailable": true
      },
      {
        "name": "Maamoul Cookies",
        "description": "Maamoul filled with dates or walnuts",
        "price": 15.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1571197119731-8cafceceeb4f5?w=500",
        "calories": 280,
        "protein": 5,
        "isAvailable": true
      },
      {
        "name": "Chocolate Cookies",
        "description": "Homemade cookies with chocolate chips",
        "price": 18.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1499636136210-a505d8d9be4d?w=500",
        "calories": 300,
        "protein": 6,
        "isAvailable": true
      },
      {
        "name": "Mixed Nuts",
        "description": "Mix of almonds, walnuts, and cashews",
        "price": 20.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1508747744061-029b0bd5d1ee1?w=500",
        "calories": 320,
        "protein": 10,
        "isAvailable": true
      },
      {
        "name": "Small Cheesecake",
        "description": "No-bake cheesecake pieces",
        "price": 25.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1533134242302-9383863b7d5d0?w=500",
        "calories": 350,
        "protein": 8,
        "isAvailable": true
      },
      {
        "name": "Yogurt Dessert",
        "description": "Dessert with yogurt, honey, and walnuts",
        "price": 18.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1488477189058-223004d91369?w=500",
        "calories": 280,
        "protein": 6,
        "isAvailable": true
      },
      {
        "name": "Chocolate Cake",
        "description": "Chocolate cake piece with dark chocolate",
        "price": 20.0,
        "category": "snack",
        "image": "https://images.unsplash.com/photo-1578985545062-f509823253ad?w=500",
        "calories": 340,
        "protein": 7,
        "isAvailable": true
      },
    ];

    try {
      for (var item in sampleData) {
        await _firestore.collection('menuItems').add(item);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error during update: $e')));
    }
  }

  int getTotalCalories() => selectedMeals.fold(0, (sum, meal) => sum + ((meal['calories'] ?? 0) as num).toInt());
  int getTotalProtein() => selectedMeals.fold(0, (sum, meal) => sum + ((meal['protein'] ?? 0) as num).toInt());
  int getTotalCarbs() => selectedMeals.fold(0, (sum, meal) => sum + ((meal['carbs'] ?? 0) as num).toInt());
  int getTotalFats() => selectedMeals.fold(0, (sum, meal) => sum + ((meal['fats'] ?? 0) as num).toInt());

  Widget _buildSummaryProgress(String label, int actual, int target) {
    final percentage = (actual / target * 100).clamp(0.0, 100.0);
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        SizedBox(width: 8),
        Text('$percentage%'),
      ],
    );
  }

  void _saveMealPlan() {

  }
}