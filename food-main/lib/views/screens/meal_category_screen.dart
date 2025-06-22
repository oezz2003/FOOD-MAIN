import 'package:flutter/material.dart';
import 'package:healthy_food/views/screens/add_meal_screen.dart';
import 'package:provider/provider.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/models/meal.dart';
import 'package:healthy_food/providers/meal_provider.dart';
import 'package:intl/intl.dart';

class MealCategoryScreen extends StatefulWidget {
  final MealType mealType;
  final String title;

  const MealCategoryScreen({
    Key? key,
    required this.mealType,
    required this.title,
  }) : super(key: key);

  @override
  State<MealCategoryScreen> createState() => _MealCategoryScreenState();
}

class _MealCategoryScreenState extends State<MealCategoryScreen> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: context.read<MealProvider>().selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: kTextPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != context.read<MealProvider>().selectedDate) {
      context.read<MealProvider>().setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<MealProvider>(
                builder: (context, mealProvider, child) {
                  if (mealProvider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    );
                  }

                  final meals = mealProvider.getMealsByType(
                    widget.mealType,
                    mealProvider.selectedDate,
                  );
                  
                  return meals.isEmpty
                      ? _buildEmptyState()
                      : _buildMealsList(meals);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealScreen(
                mealType: widget.mealType,
                selectedDate: context.read<MealProvider>().selectedDate, mealToEdit: null,
              ),
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: kTextPrimaryColor),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimaryColor,
                  ),
                ),
              ),
              Consumer<MealProvider>(
                builder: (context, mealProvider, child) {
                  return TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      DateFormat('d/M/yyyy').format(mealProvider.selectedDate),
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          Consumer<MealProvider>(
            builder: (context, mealProvider, child) {
              final meals = mealProvider.getMealsByType(
                widget.mealType,
                mealProvider.selectedDate,
              );
              
              if (meals.isEmpty) {
                return Text(
                  'لم يتم إضافة وجبات لـ ${widget.title}',
                  style: TextStyle(
                    fontSize: kBodyFontSize,
                    color: kTextSecondaryColor,
                  ),
                );
              }
              
              final totalCalories = mealProvider.getTotalCalories(widget.mealType, mealProvider.selectedDate);
              final totalProteins = meals.fold(0.0, (sum, meal) => sum + meal.proteins);
              final totalCarbs = meals.fold(0.0, (sum, meal) => sum + meal.carbs);
              final totalFats = meals.fold(0.0, (sum, meal) => sum + meal.fats);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي السعرات: ${totalCalories.toStringAsFixed(1)} سعرة',
                    style: TextStyle(
                      fontSize: kBodyFontSize,
                      color: kTextSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'البروتين: ${totalProteins.toStringAsFixed(1)}جم • الكربوهيدرات: ${totalCarbs.toStringAsFixed(1)}جم • الدهون: ${totalFats.toStringAsFixed(1)}جم',
                    style: TextStyle(
                      fontSize: 12,
                      color: kTextSecondaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: kTextSecondaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'لم يتم إضافة وجبات بعد',
            style: TextStyle(
              fontSize: kBodyFontSize,
              color: kTextSecondaryColor,
            ),
          ),
          Text(
            'اضغط + لإضافة وجبة',
            style: TextStyle(
              fontSize: kCaptionFontSize,
              color: kTextSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(List<Meal> meals) {
    return ListView.builder(
      padding: EdgeInsets.all(kDefaultPadding),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
          elevation: 2,
          child: Dismissible(
            key: Key(meal.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              Provider.of<MealProvider>(context, listen: false).removeMeal(meal.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('الوجبة ${meal.name} تم حذفها')),
              );
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.redAccent,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: meal.imageUrl.isNotEmpty
                    ? Image.network(
                        meal.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.restaurant,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
              title: Text(
                meal.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kTextPrimaryColor,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.description,
                    style: TextStyle(color: kTextSecondaryColor, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${meal.calories.toStringAsFixed(1)} سعرة حرارية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: kAccentColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMealScreen(
                        mealType: widget.mealType,
                        selectedDate: context.read<MealProvider>().selectedDate,
                        mealToEdit: meal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}