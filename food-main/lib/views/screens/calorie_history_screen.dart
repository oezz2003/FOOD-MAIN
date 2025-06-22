import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/models/meal_history.dart';

class CalorieHistoryScreen extends StatefulWidget {
  const CalorieHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CalorieHistoryScreen> createState() => _CalorieHistoryScreenState();
}

class _CalorieHistoryScreenState extends State<CalorieHistoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String selectedPeriod = 'Week';
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kGradientStart,
              kGradientMiddle,
              kGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildPeriodSelector(),
              _buildTabBar(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAddMealButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 20),
          Text(
            'Calorie History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Day', 'Week', 'Month'].map((period) {
          bool isSelected = selectedPeriod == period;
          return GestureDetector(
            onTap: () => setState(() => selectedPeriod = period),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? kGradientStart : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        children: [
          _buildTab(0, 'Overview', Icons.pie_chart),
          SizedBox(width: 15),
          _buildTab(1, 'History', Icons.history),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    bool isSelected = selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTabIndex = index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? kGradientStart : Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? kGradientStart : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return selectedTabIndex == 0 ? _buildOverview() : _buildHistoryList();
  }

  Widget _buildOverview() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('meal_history')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        List<MealHistory> meals = snapshot.data!.docs
            .map((doc) => MealHistory.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildCalorieChart(meals),
              SizedBox(height: 20),
              _buildNutrientDistribution(meals),
              SizedBox(height: 20),
              _buildMealTypeDistribution(meals),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalorieChart(List<MealHistory> meals) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calorie Intake',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kGradientStart,
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getCalorieData(meals),
                    isCurved: true,
                    color: kGradientStart,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: kGradientStart.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getCalorieData(List<MealHistory> meals) {
    // Implementation for calorie data points
    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), index * 100.0);
    });
  }

  Widget _buildNutrientDistribution(List<MealHistory> meals) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrient Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kGradientStart,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildNutrientProgress('Proteins', 0.7, Colors.blue),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildNutrientProgress('Carbs', 0.5, Colors.orange),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildNutrientProgress('Fats', 0.3, Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientProgress(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: value,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 8,
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kGradientStart,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeDistribution(List<MealHistory> meals) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kGradientStart,
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.red,
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: Colors.blue,
                    value: 40,
                    title: '40%',
                    radius: 50,
                    titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('meal_history')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        List<MealHistory> meals = snapshot.data!.docs
            .map((doc) => MealHistory.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        if (meals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.no_meals,
                  size: 64,
                  color: Colors.white.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  'No meals recorded yet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return _buildMealHistoryItem(meal);
          },
        );
      },
    );
  }

  Widget _buildMealHistoryItem(MealHistory meal) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: kGradientStart.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getMealTypeIcon(meal.mealType),
            color: kGradientStart,
          ),
        ),
        title: Text(
          meal.mealName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy - h:mm a').format(meal.dateTime),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${meal.calories.round()} kcal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kGradientStart,
              ),
            ),
            Text(
              meal.mealType,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.apple;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildAddMealButton() {
    return FloatingActionButton(
      onPressed: () {
      },
      backgroundColor: Colors.white,
      child: Icon(Icons.add, color: kGradientStart),
    );
  }
} 