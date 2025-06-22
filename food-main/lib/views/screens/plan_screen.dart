import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';

import 'package:healthy_food/providers/meal_provider.dart';
import 'package:healthy_food/services/firebase_service.dart';
import 'package:healthy_food/models/meal.dart' as meal;
import 'package:healthy_food/models/user_goals.dart' as user_goals;

class PlanScreen extends StatefulWidget {
  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _firebaseService = FirebaseService();
  late Future<Map<String, dynamic>> _initialDataFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialDataFuture = _fetchInitialData();
  }

  Future<Map<String, dynamic>> _fetchInitialData() async {
    try {
      final goals = await _firebaseService.getUserGoals();
      final meals = await _firebaseService.getMealsForDate(DateTime.now());
      
      return {
        'userGoals': goals,
        'todayMeals': meals,
      };
    } catch (e) {
      print('Error fetching initial data: $e');
      return {
        'userGoals': null,
        'todayMeals': [],
      };
    }
  }

  void _refreshData() {
    setState(() {
      _initialDataFuture = _fetchInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _initialDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user_goals.UserGoals? userGoals = snapshot.data!['userGoals'] as user_goals.UserGoals?;
            final List<meal.Meal> todayMeals = (snapshot.data!['todayMeals'] as List<dynamic>).map((e) => e as meal.Meal).toList();

            return Column(
              children: [
                _buildHeader(userGoals, todayMeals, _refreshData),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodayView(userGoals, todayMeals),
                      _buildWeekView(userGoals),
                      _buildGoalsView(userGoals),
                    ],
                  ),
                ),
              ],
            );
          }
          return Center(child: Text('No data available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: _showAddMealDialog,
        child: Icon(Icons.add),
            backgroundColor: kPrimaryColor,
      ),
    );
  }

  Widget _buildHeader(user_goals.UserGoals? userGoals, List<meal.Meal> todayMeals, VoidCallback onRefresh) {
    return Container(
      padding: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Plan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimaryColor,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh, color: kPrimaryColor),
              ),
            ],
          ),
          TabBar(
            controller: _tabController,
            labelColor: kPrimaryColor,
            unselectedLabelColor: kTextSecondaryColor,
            indicatorColor: kPrimaryColor,
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Week'),
              Tab(text: 'Goals'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayView(user_goals.UserGoals? userGoals, List<meal.Meal> todayMeals) {
    if (userGoals == null) {
      return Center(child: Text('No goals set'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlannedMeals(todayMeals),
          SizedBox(height: 24),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildPlannedMeals(List<meal.Meal> todayMeals) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Meals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimaryColor,
                  ),
                ),
                Text(
                  '${todayMeals.length} meals',
                  style: TextStyle(
                    fontSize: kCaptionFontSize,
                    color: kTextSecondaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (todayMeals.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.restaurant, size: 48, color: kTextSecondaryColor),
                    SizedBox(height: 8),
                    Text(
                      'No meals added yet',
                      style: TextStyle(color: kTextSecondaryColor),
                    ),
                  ],
                ),
              )
            else
              ...todayMeals.map((meal) => _buildMealItem(meal)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(meal.Meal meal) {
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        await _firebaseService.deleteMeal(meal.id, meal.dateTime.toIso8601String());
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${meal.name} deleted')),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getMealTypeColor(meal.type.toString()),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getMealTypeDisplayName(meal.type.toString())} - ${meal.time}',
                    style: TextStyle(
                      fontSize: kBodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimaryColor,
                    ),
                  ),
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: kCaptionFontSize,
                      color: kTextSecondaryColor,
                    ),
                  ),
                  Text(
                    '${meal.calories.round()} cal',
                    style: TextStyle(
                      fontSize: kCaptionFontSize,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView(user_goals.UserGoals? userGoals) {
    if (userGoals == null) return Center(child: Text('No goals set'));

    return Center(
      child: Text(
        'Weekly view is coming soon',
        style: TextStyle(color: kTextSecondaryColor),
      ),
    );
  }

  Widget _buildGoalsView(user_goals.UserGoals? userGoals) {
    if (userGoals == null) return Center(child: Text('No goals set'));

    return SingleChildScrollView(
      padding: EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalCard('Daily Calories', '${userGoals.dailyCalories.round()}', 'kcal', Icons.local_fire_department),
          SizedBox(height: 16),
          _buildGoalCard('Daily Protein', '${userGoals.dailyProtein.round()}', 'g', Icons.fitness_center),
          SizedBox(height: 16),
          _buildGoalCard('Daily Carbs', '${userGoals.dailyCarbs.round()}', 'g', Icons.bakery_dining),
          SizedBox(height: 16),
          _buildGoalCard('Daily Fats', '${userGoals.dailyFats.round()}', 'g', Icons.oil_barrel),
          SizedBox(height: 16),
          _buildGoalCard('Daily Steps', '${userGoals.dailySteps}', 'steps', Icons.directions_walk),
          SizedBox(height: 16),
          _buildGoalCard('Daily Water', '${userGoals.dailyWater.toStringAsFixed(1)}', 'L', Icons.water_drop),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showEditGoalsDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultRadius),
              ),
            ),
            child: Text(
              'Edit Goals',
              style: TextStyle(
                fontSize: kBodyFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, String value, String unit, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kPrimaryColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: kBodyFontSize,
                      color: kTextPrimaryColor,
                    ),
                  ),
                  Text(
                    '$value $unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextPrimaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Based on your progress, consider adding more protein and vegetables to your dinner.',
              style: TextStyle(
                fontSize: kBodyFontSize,
                color: kTextSecondaryColor,
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                },
                child: Text(
                  'Explore More',
                  style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Meal'),
        content: Text('Meal addition dialog would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
        
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Goals'),
        content: Text('Goals editing dialog would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
             
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType) {
      case 'MealType.breakfast':
        return Colors.orange;
      case 'MealType.lunch':
        return Colors.green;
      case 'MealType.dinner':
        return Colors.blue;
      case 'MealType.snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMealTypeDisplayName(String mealType) {
    switch (mealType) {
      case 'MealType.breakfast':
        return 'Breakfast';
      case 'MealType.lunch':
        return 'Lunch';
      case 'MealType.dinner':
        return 'Dinner';
      case 'MealType.snack':
        return 'Snack';
      default:
        return 'Meal';
    }
  }
}