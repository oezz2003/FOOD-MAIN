import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const _historyKey = 'mealHistory';
  static List<Map<String, dynamic>> _mealHistory = [];
  static bool _isInitialized = false;

  static Future<void> _initialize() async {
    if (_isInitialized) return;
    await _loadHistory();
    _isInitialized = true;
  }

  static Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_historyKey);
    if (historyString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(historyString);
        _mealHistory = decodedList.map((item) {
          final decodedItem = item as Map<String, dynamic>;
          decodedItem['date'] = DateTime.parse(decodedItem['date'] as String);
          decodedItem['meals'] = List<Map<String, dynamic>>.from(decodedItem['meals']);
          return decodedItem;
        }).toList();
      } catch (e) {
        print('Error decoding history: $e');
        _mealHistory = [];
      }
    } else {
      _mealHistory = [];
    }
  }

  static Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    // This function handles DateTime serialization during JSON encoding.
    Object? toEncodable(dynamic object) {
      if (object is DateTime) {
        return object.toIso8601String();
      }
      return object;
    }

    // Encode the entire history object using the custom encoder.
    final historyString = jsonEncode(_mealHistory, toEncodable: toEncodable);
    await prefs.setString(_historyKey, historyString);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    await _initialize();
    _mealHistory.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return _mealHistory;
  }

  static Future<void> addPlan(Map<String, dynamic> plan) async {
    await _initialize();
    final newDate = plan['date'] as DateTime;
    _mealHistory.removeWhere((entry) {
      final entryDate = entry['date'] as DateTime;
      return DateFormat('yyyy-MM-dd').format(entryDate) == DateFormat('yyyy-MM-dd').format(newDate);
    });
    _mealHistory.add(plan);
    await _saveHistory();
  }
}

class HistoryScreen extends StatefulWidget {
  final Map<String, dynamic>? savedPlan;

  const HistoryScreen({Key? key, this.savedPlan}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistoryData();
  }

  Future<List<Map<String, dynamic>>> _loadHistoryData() async {
    if (widget.savedPlan != null) {
      await HistoryService.addPlan(widget.savedPlan!);
    }
    return HistoryService.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green.shade600));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }
          final historyEntries = snapshot.data!;
          return _buildHistoryList(historyEntries);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Meal History', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No History Yet',
            style: TextStyle(fontSize: 22, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Create a meal plan to see your history here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> historyEntries) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: historyEntries.length,
      itemBuilder: (context, index) {
        final entry = historyEntries[index];
        return _buildHistoryCard(entry);
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final date = entry['date'] as DateTime;
    final meals = List<Map<String, dynamic>>.from(entry['meals']);
    final totalCalories = entry['totalCalories'] as int;

    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Icon(Icons.calendar_today, color: Colors.green),
        title: Text(
          DateFormat('MMMM d, y').format(date),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('${meals.length} meals | $totalCalories kcal'),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildTotalNutritionRow(entry),
                Divider(height: 24),
                ...meals.map((meal) => _buildMealItem(meal)).toList(),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalNutritionRow(Map<String, dynamic> entry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNutritionChip('Calories', (entry['totalCalories'] as int).toString(), 'kcal', Colors.orange),
        _buildNutritionChip('Protein', (entry['totalProtein'] as int).toString(), 'g', Colors.red),
        _buildNutritionChip('Carbs', (entry['totalCarbs'] as int).toString(), 'g', Colors.amber),
        _buildNutritionChip('Fats', (entry['totalFats'] as int).toString(), 'g', Colors.purple),
      ],
    );
  }

  Widget _buildNutritionChip(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3))
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            meal['image'] ?? 'https://via.placeholder.com/150',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(width: 50, height: 50, color: Colors.grey[200], child: Icon(Icons.restaurant, color: Colors.grey[600])),
          ),
        ),
        title: Text(
          meal['name'] ?? 'Unknown Meal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${meal['calories'] ?? 0} kcal | P:${meal['protein'] ?? 0}g C:${meal['carbs'] ?? 0}g F:${meal['fats'] ?? 0}g',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }
}