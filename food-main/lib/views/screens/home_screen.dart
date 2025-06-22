import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/routes.dart';
import 'package:healthy_food/models/history_screen.dart';
import 'package:healthy_food/models/meal_plan.dart';
import 'package:healthy_food/providers/meal_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String userName = 'User';
  String userImageUrl = '';
  bool isLoadingUser = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sample data - replace with actual data from your providers
  Map<String, dynamic> todaySummary = {
    'totalCalories': 0,
    'targetCalories': 2200,
    'mealCount': 0,
    'targetMeals': 4,
    'waterGlasses': 6,
    'targetWater': 8,
    'proteins': 0.0,
    'carbs': 0.0,
    'fats': 0.0,
  };

  List<String> motivationQuotes = [
    "Your body is your temple. Keep it pure and clean for the soul to reside in.",
    "Take care of your body. It's the only place you have to live.",
    "Health is not about the weight you lose, but about the life you gain.",
    "Every healthy choice you make is an investment in your future self.",
    "Progress, not perfection. Every small step counts!",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
    _loadTodaySummary();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTodaySummary() async {
    final history = await HistoryService.getHistory();
    final today = DateTime.now();
    final todayEntry = history.firstWhere(
          (entry) {
        final entryDate = entry['date'] as DateTime;
        return DateFormat('yyyy-MM-dd').format(entryDate) ==
            DateFormat('yyyy-MM-dd').format(today);
      },
      orElse: () => {},
    );

    if (mounted) {
      if (todayEntry.isNotEmpty) {
        final meals = todayEntry['meals'] as List<dynamic>;
        double totalCalories = 0;
        double totalProteins = 0;
        double totalCarbs = 0;
        double totalFats = 0;

        for (var meal in meals) {
          totalCalories += (meal['calories'] as num).toDouble();
          totalProteins += (meal['protein'] as num).toDouble();
          totalCarbs += (meal['carbs'] as num).toDouble();
          totalFats += (meal['fats'] as num).toDouble();
        }

        setState(() {
          todaySummary['totalCalories'] = totalCalories.toInt();
          todaySummary['mealCount'] = meals.length;
          todaySummary['proteins'] = totalProteins;
          todaySummary['carbs'] = totalCarbs;
          todaySummary['fats'] = totalFats;
        });
      } else {
        setState(() {
          todaySummary['totalCalories'] = 0;
          todaySummary['mealCount'] = 0;
          todaySummary['proteins'] = 0.0;
          todaySummary['carbs'] = 0.0;
          todaySummary['fats'] = 0.0;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
          setState(() {
            userName = currentUser.displayName!;
            userImageUrl = currentUser.photoURL ?? '';
            isLoadingUser = false;
          });
        } else {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            setState(() {
              userName = userData['name'] ?? 'User';
              userImageUrl = userData['imageUrl'] ?? '';
              isLoadingUser = false;
            });
          } else {
            setState(() {
              userName = 'User';
              isLoadingUser = false;
            });
          }
        }
      } else {
        setState(() {
          userName = 'User';
          isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        userName = 'User';
        isLoadingUser = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      // Already on home
        break;
      case 1:

        Navigator.pushNamed(context, AppRoutes.meals)?.then((_) => _loadTodaySummary());
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MealPlanScreen()),
        )?.then((_) => _loadTodaySummary());
        break;
      case 3:

        Navigator.pushNamed(context, AppRoutes.profile)?.then((_) => _loadTodaySummary());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnhancedHeader(),
                  SizedBox(height: 25),
                  _buildTodaySummaryCard(),
                  SizedBox(height: 25),
                  _buildQuickActionsRow(),
                  SizedBox(height: 25),
                  _buildTodaysMealHighlight(),
                  SizedBox(height: 25),
                  _buildProgressStatsCards(),
                  SizedBox(height: 25),
                  _buildMotivationTip(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kDefaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: userImageUrl.isNotEmpty
                  ? Image.network(
                userImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              )
                  : _buildDefaultAvatar(),
            ),
          ),
          SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HealthyBite',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                isLoadingUser
                    ? Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : Text(
                  'Welcome, $userName',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {

            },
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.green.shade600,
        size: 30,
      ),
    );
  }

  Widget _buildTodaySummaryCard() {
    double calorieProgress = todaySummary['totalCalories'] / todaySummary['targetCalories'];
    double mealProgress = todaySummary['mealCount'] / todaySummary['targetMeals'];
    double waterProgress = todaySummary['waterGlasses'] / todaySummary['targetWater'];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimaryColor,
                ),
              ),
              Icon(Icons.today, color: Colors.green.shade600),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem(
                '${todaySummary['totalCalories']}',
                '${todaySummary['targetCalories']}',
                'Calories',
                calorieProgress,
                Colors.orange.shade400,
              ),
              _buildProgressItem(
                '${todaySummary['mealCount']}',
                '${todaySummary['targetMeals']}',
                'Meals',
                mealProgress,
                Colors.green.shade400,
              ),
              _buildProgressItem(
                '${todaySummary['waterGlasses']}',
                '${todaySummary['targetWater']}',
                'Water',
                waterProgress,
                Colors.blue.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String current, String target, String label, double progress, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 4,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              current,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kTextPrimaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: kTextSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'of $target',
          style: TextStyle(
            fontSize: 10,
            color: kTextSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kTextPrimaryColor,
          ),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(
              Icons.add_circle_outline,
              'Add Meal',
              Colors.green.shade400,
                  () => Navigator.pushNamed(context, AppRoutes.meals),
            ),
            _buildQuickActionItem(
              Icons.local_drink_outlined,
              'Log Water',
              Colors.blue.shade400,
                  () {

              },
            ),
            _buildQuickActionItem(
              Icons.fitness_center,
              'Workout',
              Colors.red.shade400,
                  () {

              },
            ),
            _buildQuickActionItem(
              Icons.analytics_outlined,
              'Reports',
              Colors.purple.shade400,
                  () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: kTextSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysMealHighlight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Special",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextPrimaryColor,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.meals),
              child: Text(
                'View All',
                style: TextStyle(color: Colors.green.shade600),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: kCardBackgroundColor,
            borderRadius: BorderRadius.circular(kDefaultRadius),
            boxShadow: [
              BoxShadow(
                color: kShadowColor,
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius)),
                child: Image.asset(
                  'assets/images/egg.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Greek Salad',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kTextPrimaryColor,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '350 Cal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A healthy and balanced meal full of fresh vegetables and protein.',
                      style: TextStyle(
                        fontSize: kBodyFontSize,
                        color: kTextSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: kTextSecondaryColor),
                        SizedBox(width: 4),
                        Text('15 min', style: TextStyle(fontSize: 12, color: kTextSecondaryColor)),
                        SizedBox(width: 15),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text('4.8', style: TextStyle(fontSize: 12, color: kTextSecondaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Progress Stats",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kTextPrimaryColor,
          ),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Protein',
                '${todaySummary['proteins'].toStringAsFixed(1)}g',
                '120g',
                Colors.red.shade400,
                Icons.fitness_center,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Carbs',
                '${todaySummary['carbs'].toStringAsFixed(0)}g',
                '300g',
                Colors.orange.shade400,
                Icons.grain,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Fats',
                '${todaySummary['fats'].toStringAsFixed(1)}g',
                '80g',
                Colors.yellow.shade600,
                Icons.opacity,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Weight this week',
                '-0.5kg',
                'Goal: -2kg',
                Colors.green.shade400,
                Icons.trending_down,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String target, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextPrimaryColor,
            ),
          ),
          Text(
            target,
            style: TextStyle(
              fontSize: 12,
              color: kTextSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationTip() {
    String randomQuote = motivationQuotes[DateTime.now().day % motivationQuotes.length];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kDefaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                "Tip of the Day",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            randomQuote,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final List<IconData> navIcons = [
      Icons.home,
      Icons.restaurant,
      Icons.fastfood,
      Icons.person,
    ];

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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navIcons.length, (index) {
          return IconButton(
            onPressed: () => _onItemTapped(index),
            icon: Icon(
              navIcons[index],
              size: 28,
              color: _selectedIndex == index ? Colors.green.shade600 : Colors.grey,
            ),
          );
        }),
      ),
    );
  }
}