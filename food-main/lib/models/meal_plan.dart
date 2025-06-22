import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthy_food/models/history_screen.dart';
import 'package:healthy_food/models/menu_screen.dart';

class MealPlanScreen extends StatefulWidget {
  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}


class _MealPlanScreenState extends State<MealPlanScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _progressAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _cardAnimation;

  Map<String, dynamic>? userGoals;
  List<Map<String, dynamic>> mealPlans = [];
  List<Map<String, dynamic>> selectedMeals = [];
  Map<String, dynamic> dailyProgress = {};
  bool isLoading = true;
  String selectedCategory = 'All';
  List<String> categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _progressAnimationController, curve: Curves.easeInOut),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _cardAnimationController, curve: Curves.elasticOut),
    );
  }

  void _initializeData() async {
    try {
      await Future.wait([
        _fetchUserGoals(),
        _fetchMealPlans(),
        _fetchSelectedMealsForDate(),
      ]);
      _calculateDailyProgress();
      _startAnimations();
      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error initializing data: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _startAnimations() {
    _cardAnimationController.forward();
    _progressAnimationController.forward();
  }

  Future<void> _fetchUserGoals() async {
    try {
      userGoals = {
        'dailyCalories': 2000.0,
        'dailyProtein': 150.0,
        'dailyCarbs': 250.0,
        'dailyFats': 65.0,
        'dailyWater': 2.5,
        'dailySteps': 10000.0,
        'dailyFiber': 30.0,
      };
      await Future.delayed(Duration.zero);
    } catch (e) {
      print("Error fetching goals: $e");
    }
  }

  Future<void> _fetchMealPlans() async {
    try {
      Query query = _firestore.collection('menuItems');
      if (selectedCategory != 'All') {
        // Firestore uses lowercase category names
        query = query.where('category', isEqualTo: selectedCategory.toLowerCase());
      }
      final QuerySnapshot snapshot = await query.get();
      mealPlans = snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      })
          .toList();
    } catch (e) {
      print("Error fetching meals: $e");
      // Fallback to empty list on error
      mealPlans = [];
    }
  }

  Future<void> _fetchSelectedMealsForDate() async {
    selectedMeals = [];
    await Future.delayed(Duration.zero);
  }

  Future<void> _saveMealPlan() async {
    _showSuccessSnackBar('Plan saved successfully!');

    // تجهيز بيانات الخطة لتمريرها إلى شاشة السجل
    final planData = {
      'date': selectedDate,
      'meals': selectedMeals,
      'totalCalories': getTotalCalories(),
      'totalProtein': getTotalProtein(),
      'totalCarbs': getTotalCarbs(),
      'totalFats': getTotalFats(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(savedPlan: planData),
      ),
    );
  }

  void _calculateDailyProgress() {
    dailyProgress = {
      'calories':
      _calculateProgress(getTotalCalories(), userGoals?['dailyCalories'] ?? 1.0),
      'protein':
      _calculateProgress(getTotalProtein(), userGoals?['dailyProtein'] ?? 1.0),
      'carbs':
      _calculateProgress(getTotalCarbs(), userGoals?['dailyCarbs'] ?? 1.0),
      'fats':
      _calculateProgress(getTotalFats(), userGoals?['dailyFats'] ?? 1.0),
    };
  }

  double _calculateProgress(num consumed, num goal) {
    double percentage = goal > 0 ? (consumed / goal) * 100 : 0;
    return percentage.clamp(0.0, 100.0);
  }

  void _addMealToPlan(Map<String, dynamic> meal) {
    setState(() {
      selectedMeals.add({
        ...meal,
        'calories': _toIntSafe(meal['calories']),
        'protein': _toIntSafe(meal['protein']),
        'carbs': _toIntSafe(meal['carbs']),
        'fats': _toIntSafe(meal['fats']),
        'addedAt': DateTime.now(),
      });
      _calculateDailyProgress();
    });

    _showMealAddedAnimation();
  }

  void _removeMealFromPlan(Map<String, dynamic> meal) {
    setState(() {
      selectedMeals.removeWhere((m) => m['id'] == meal['id']);
      _calculateDailyProgress();
    });
  }

  int getTotalCalories() => selectedMeals.fold(
      0, (sum, meal) => sum + _toIntSafe(meal['calories']));
  int getTotalProtein() => selectedMeals.fold(
      0, (sum, meal) => sum + _toIntSafe(meal['protein']));
  int getTotalCarbs() => selectedMeals.fold(
      0, (sum, meal) => sum + _toIntSafe(meal['carbs']));
  int getTotalFats() => selectedMeals.fold(
      0, (sum, meal) => sum + _toIntSafe(meal['fats']));

  int _toIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt() ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  double _toDoubleSafe(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is int) return value.toDouble();
    return 0.0;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showMealAddedAnimation() {
    _cardAnimationController.reset();
    _cardAnimationController.forward();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text(message),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 8),
          Text(message),
        ],
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _buildEnhancedGoalItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double progress, Color color, String current, String target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            Text('$current / $target', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Plan for ${_formatDateForDisplay(selectedDate)}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(Duration(days: 365)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
                await _fetchSelectedMealsForDate();
                _calculateDailyProgress();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Change Date'),
          ),
        ],
      ),
    );
  }

  String _formatDateForDisplay(DateTime date) {
    final List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) async {
                setState(() {
                  selectedCategory = category;
                  isLoading = true;
                });
                await _fetchMealPlans();
                setState(() => isLoading = false);
              },
              selectedColor: Colors.green.shade100,
              checkmarkColor: Colors.green.shade700,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Smart Meal Plan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text('Loading your meal plan...',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          setState(() => isLoading = true);
          try {
            await Future.wait([
              _fetchUserGoals(),
              _fetchMealPlans(),
              _fetchSelectedMealsForDate(),
            ]);
            _calculateDailyProgress();
            _startAnimations();
          } catch (e) {
            print("Error refreshing data: $e");
          } finally {
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
              SizedBox(height: 20),
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cardAnimation.value,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flag,
                                    color: Colors.green.shade600,
                                    size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Your Daily Goals',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildEnhancedGoalItem(
                              'Calories',
                              '${userGoals?['dailyCalories']}',
                              Icons.local_fire_department,
                              Colors.orange,
                            ),
                            SizedBox(height: 8),
                            _buildEnhancedGoalItem(
                              'Protein',
                              '${userGoals?['dailyProtein']} g',
                              Icons.fitness_center,
                              Colors.red,
                            ),
                            SizedBox(height: 8),
                            _buildEnhancedGoalItem(
                              'Carbs',
                              '${userGoals?['dailyCarbs']} g',
                              Icons.grain,
                              Colors.amber,
                            ),
                            SizedBox(height: 8),
                            _buildEnhancedGoalItem(
                              'Fats',
                              '${userGoals?['dailyFats']} g',
                              Icons.opacity,
                              Colors.purple,
                            ),
                            SizedBox(height: 8),
                            _buildEnhancedGoalItem(
                              'Fiber',
                              '${userGoals?['dailyFiber']} g',
                              Icons.eco,
                              Colors.teal,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up,
                              color: Colors.blue.shade600, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Daily Progress',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildProgressIndicator(
                        'Calories',
                        dailyProgress['calories'] ?? 0.0,
                        Colors.orange,
                        getTotalCalories().toString(),
                        userGoals?['dailyCalories'].toString() ?? '0',
                      ),
                      SizedBox(height: 16),
                      _buildProgressIndicator(
                        'Protein',
                        dailyProgress['protein'] ?? 0.0,
                        Colors.red,
                        '${getTotalProtein()}g',
                        '${userGoals?['dailyProtein']}g',
                      ),
                      SizedBox(height: 16),
                      _buildProgressIndicator(
                        'Carbs',
                        dailyProgress['carbs'] ?? 0.0,
                        Colors.amber,
                        '${getTotalCarbs()}g',
                        '${userGoals?['dailyCarbs']}g',
                      ),
                      SizedBox(height: 16),
                      _buildProgressIndicator(
                        'Fats',
                        dailyProgress['fats'] ?? 0.0,
                        Colors.purple,
                        '${getTotalFats()}g',
                        '${userGoals?['dailyFats']}g',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Filter by Category',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildCategoryFilter(),
              SizedBox(height: 20),
              if (selectedMeals.isNotEmpty) ...[
                Text('Selected Meals (${selectedMeals.length})',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: selectedMeals.length,
                  itemBuilder: (context, index) {
                    var meal = selectedMeals[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Dismissible(
                        key: Key('selected_meal_${meal['id']}_$index'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeMealFromPlan(meal),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              meal['image'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.restaurant,
                                      color: Colors.grey[600]),
                                );
                              },
                            ),
                          ),
                          title: Text(
                              meal['name'] ?? 'Name not available',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${meal['calories'] ?? 0} calories'),
                              Text(
                                  'Protein: ${meal['protein'] ?? 0}g | Carbs: ${meal['carbs'] ?? 0}g',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600])),
                            ],
                          ),
                          trailing: Icon(Icons.check_circle,
                              color: Colors.green, size: 30),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
              Text('Choose your meals from the menu',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: mealPlans.length,
                itemBuilder: (context, index) {
                  var meal = mealPlans[index];
                  bool isSelected =
                  selectedMeals.any((m) => m['id'] == meal['id']);
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    elevation: isSelected ? 8 : 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(color: Colors.green, width: 2)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          meal['image'] ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(Icons.restaurant,
                                  color: Colors.grey[600]),
                            );
                          },
                        ),
                      ),
                      title: Text(
                        meal['name'] ?? 'Name not available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                          isSelected ? Colors.green.shade700 : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('A${_toIntSafe(meal['calories'])} calories'),
                          Text(
                            '${meal['category'] ?? 'Not specified'} | ${meal['description'] ?? ''}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (meal['rating'] != null)
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.orange, size: 16),
                                SizedBox(width: 4),
                                Text('${meal['rating']}',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          if (meal['price'] != null)
                            Chip(
                              label: Text('${_toIntSafe(meal['price'])} LE'),
                              backgroundColor: Colors.green.shade100,
                              labelStyle: TextStyle(
                                  color: Colors.green.shade800),
                            ),
                        ],
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                          color: Colors.green, size: 30)
                          : ElevatedButton.icon(
                        onPressed: () => _addMealToPlan(meal),
                        icon: Icon(Icons.add, size: 18),
                        label: Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedMeals.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _saveMealPlan,
        icon: Icon(Icons.save),
        label: Text('Save Plan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      )
          : null,
    );
  }

  Widget _buildSummaryProgress(
      String label, int current, int target) {
    double percentage = target > 0 ? (current / target) * 100 : 0;
    Color color = percentage > 100
        ? Colors.orange
        : percentage > 80
        ? Colors.green
        : Colors.blue;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(fontSize: 12)),
          Text('$current/$target (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }
}