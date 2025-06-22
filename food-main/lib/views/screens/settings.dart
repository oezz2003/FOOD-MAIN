import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic> userGoals = {
    'dailyCalories': 2000.0,
    'dailyCarbs': 250.0,
    'dailyFats': 65.0,
    'dailyProtein': 150.0,
    'dailySteps': 10000.0,
    'dailyWater': 2.5,
  };

  Map<String, dynamic> todayProgress = {
    'calories': 0.0,
    'carbs': 0.0,
    'fats': 0.0,
    'protein': 0.0,
    'steps': 0.0,
    'water': 0.0,
  };

  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserGoals();
    _loadTodayProgress();
  }

  Future<void> _loadUserGoals() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('userGoals')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          // Fixed: Ensure all values are converted to double
          final data = doc.data() ?? {};
          userGoals = {
            'dailyCalories': (data['dailyCalories'] ?? 2000).toDouble(),
            'dailyCarbs': (data['dailyCarbs'] ?? 250).toDouble(),
            'dailyFats': (data['dailyFats'] ?? 65).toDouble(),
            'dailyProtein': (data['dailyProtein'] ?? 150).toDouble(),
            'dailySteps': (data['dailySteps'] ?? 10000).toDouble(),
            'dailyWater': (data['dailyWater'] ?? 2.5).toDouble(),
          };
          isLoading = false;
        });
      } else {
        await _firestore
            .collection('userGoals')
            .doc(user.uid)
            .set(userGoals);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading goals: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadTodayProgress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final mealsQuery = await _firestore
          .collection('meals')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: todayStr)
          .get();

      double totalCalories = 0.0;
      double totalCarbs = 0.0;
      double totalFats = 0.0;
      double totalProtein = 0.0;

      for (var doc in mealsQuery.docs) {
        final meal = doc.data();
        totalCalories += (meal['calories'] ?? 0).toDouble();
        totalCarbs += (meal['carbs'] ?? 0).toDouble();
        totalFats += (meal['fats'] ?? 0).toDouble();
        totalProtein += (meal['protein'] ?? 0).toDouble();
      }

      final waterDoc = await _firestore
          .collection('waterIntake')
          .doc('${user.uid}_$todayStr')
          .get();

      double waterIntake = 0.0;
      if (waterDoc.exists) {
        waterIntake = (waterDoc.data()?['amount'] ?? 0).toDouble();
      }

      setState(() {
        todayProgress = {
          'calories': totalCalories,
          'carbs': totalCarbs,
          'fats': totalFats,
          'protein': totalProtein,
          'steps': 5000.0,
          'water': waterIntake,
        };
      });
    } catch (e) {
      print('Error loading today progress: $e');
    }
  }

  Future<void> _updateGoals() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('userGoals')
          .doc(user.uid)
          .set({
        ...userGoals,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goals saved successfully! 🎯'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving goals: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProgressCard(String title, String unit, double current, double goal, Color color, IconData icon) {
    double percentage = goal > 0 ? (current / goal) * 100 : 0;
    percentage = percentage > 100 ? 100 : percentage;

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Fixed: Use double values
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${current.toInt()}/${goal.toInt()} $unit',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8.0,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percentage.toInt()}% Complete',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Remaining ${(goal - current).toInt()} $unit',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableGoalCard(String title, String key, String unit, Color color, IconData icon) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Fixed: Use double values
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 80.0,
              child: TextFormField(
                initialValue: userGoals[key].toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffix: Text(unit),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                ),
                onChanged: (value) {
                  final numValue = double.tryParse(value);
                  if (numValue != null) {
                    setState(() {
                      userGoals[key] = numValue;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Goals'),
          backgroundColor: Colors.green.shade600,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals 🎯'),
        backgroundColor: Colors.green.shade600,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateGoals();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
                _loadUserGoals();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserGoals();
          await _loadTodayProgress();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 48.0,
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Keep Going!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Track your daily goals and achieve a healthy lifestyle',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              if (!isEditing) ...[

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.today, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      const Text(
                        'Today\'s Progress',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateTime.now().toString().split(' ')[0],
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12.0),

                _buildProgressCard(
                  'Calories',
                  'cal',
                  todayProgress['calories'].toDouble(),
                  userGoals['dailyCalories'].toDouble(),
                  Colors.orange,
                  Icons.local_fire_department,
                ),

                _buildProgressCard(
                  'Protein',
                  'g',
                  todayProgress['protein'].toDouble(),
                  userGoals['dailyProtein'].toDouble(),
                  Colors.red,
                  Icons.fitness_center,
                ),

                _buildProgressCard(
                  'Carbs',
                  'g',
                  todayProgress['carbs'].toDouble(),
                  userGoals['dailyCarbs'].toDouble(),
                  Colors.blue,
                  Icons.grain,
                ),

                _buildProgressCard(
                  'Fats',
                  'g',
                  todayProgress['fats'].toDouble(),
                  userGoals['dailyFats'].toDouble(),
                  Colors.yellow.shade700,
                  Icons.opacity,
                ),

                _buildProgressCard(
                  'Water',
                  'L',
                  todayProgress['water'].toDouble(),
                  userGoals['dailyWater'].toDouble(),
                  Colors.blue.shade400,
                  Icons.water_drop,
                ),

                _buildProgressCard(
                  'Steps',
                  'steps',
                  todayProgress['steps'].toDouble(),
                  userGoals['dailySteps'].toDouble(),
                  Colors.green,
                  Icons.directions_walk,
                ),
              ] else ...[

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Fixed: Use double value
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.orange),
                      const SizedBox(width: 8.0),
                      const Text(
                        'Edit Goals',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12.0),

                _buildEditableGoalCard(
                  'Daily Calories',
                  'dailyCalories',
                  'cal',
                  Colors.orange,
                  Icons.local_fire_department,
                ),

                _buildEditableGoalCard(
                  'Daily Protein',
                  'dailyProtein',
                  'g',
                  Colors.red,
                  Icons.fitness_center,
                ),

                _buildEditableGoalCard(
                  'Daily Carbs',
                  'dailyCarbs',
                  'g',
                  Colors.blue,
                  Icons.grain,
                ),

                _buildEditableGoalCard(
                  'Daily Fats',
                  'dailyFats',
                  'g',
                  Colors.yellow.shade700,
                  Icons.opacity,
                ),

                _buildEditableGoalCard(
                  'Daily Water',
                  'dailyWater',
                  'L',
                  Colors.blue.shade400,
                  Icons.water_drop,
                ),

                _buildEditableGoalCard(
                  'Daily Steps',
                  'dailySteps',
                  'steps',
                  Colors.green,
                  Icons.directions_walk,
                ),
              ],

              const SizedBox(height: 20.0),


              if (!isEditing) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12.0),

                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.water_drop, color: Colors.blue),
                        title: const Text('Add Glass of Water'),
                        subtitle: const Text('Drink a glass of water (250 ml)'),
                        trailing: const Icon(Icons.add_circle, color: Colors.blue),
                        onTap: () async {
                          try {
                            final user = _auth.currentUser;
                            if (user == null) return;

                            final today = DateTime.now();
                            final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

                            await _firestore
                                .collection('waterIntake')
                                .doc('${user.uid}_$todayStr')
                                .set({
                              'amount': FieldValue.increment(0.25),
                              'date': todayStr,
                              'userId': user.uid,
                              'updatedAt': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));

                            await _loadTodayProgress();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Water glass added! 💧'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          } catch (e) {
                            print('Error adding water: $e');
                          }
                        },
                      ),
                      const Divider(height: 1.0),
                      ListTile(
                        leading: const Icon(Icons.restaurant, color: Colors.green),
                        title: const Text('Add Meal'),
                        subtitle: const Text('Log a new meal'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                        onTap: () {
                          Navigator.pushNamed(context, '/add-meal');
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 100.0),
            ],
          ),
        ),
      ),
    );
  }
}