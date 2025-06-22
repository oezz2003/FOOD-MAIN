import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/models/meal.dart';
import 'package:healthy_food/providers/meal_provider.dart';
import 'package:healthy_food/views/components/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:healthy_food/services/firebase_service.dart';
import 'package:intl/intl.dart';

class AddMealScreen extends StatefulWidget {
  final MealType mealType; 
  final DateTime selectedDate;
  final Meal? mealToEdit; 
  const AddMealScreen({
    Key? key,
    required this.mealType,
    required this.selectedDate,
    this.mealToEdit, 
  }) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _formKey = GlobalKey<FormState>();
  
  late MealType selectedMealType;
  
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // New controller for description
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinsController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    selectedMealType = widget.mealToEdit?.type ?? widget.mealType;

    if (widget.mealToEdit != null) {
      _mealNameController.text = widget.mealToEdit!.name;
      _descriptionController.text = widget.mealToEdit!.description;
      _caloriesController.text = widget.mealToEdit!.calories.toString();
      _proteinsController.text = widget.mealToEdit!.proteins.toString();
      _carbsController.text = widget.mealToEdit!.carbs.toString();
      _fatsController.text = widget.mealToEdit!.fats.toString();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mealNameController.dispose();
    _descriptionController.dispose(); 
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final mealProvider = Provider.of<MealProvider>(context, listen: false);

      final newMeal = Meal(
        id: widget.mealToEdit?.id ?? const Uuid().v4(),
        userId: FirebaseService.userId,
        name: _mealNameController.text,
        description: _descriptionController.text,
        calories: double.parse(_caloriesController.text),
        proteins: double.parse(_proteinsController.text),
        carbs: double.parse(_carbsController.text),
        fats: double.parse(_fatsController.text),
        imageUrl: '',
        dateTime: DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          DateTime.now().hour,
          DateTime.now().minute,
        ),
        date: DateFormat('yyyy-MM-dd').format(widget.selectedDate),
        time: DateFormat('HH:mm').format(DateTime.now()),
        type: selectedMealType, protein: 20,
      );

      if (widget.mealToEdit == null) {
        await mealProvider.addMeal(newMeal);
      } else {
        await mealProvider.updateMeal(newMeal);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الوجبة تم حفظها بنجاح!')),
      );
      Navigator.pop(context); // Go back after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ الوجبة: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 20),
          Text(
            widget.mealToEdit == null ? 'Add Meal' : 'Edit Meal',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMealTypeSelector(),
          const SizedBox(height: 20),
          CustomField(
            controller: _mealNameController,
            hint: 'Meal Name',
            icon: const Icon(Icons.restaurant_menu, color: Colors.white70),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم الوجبة';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomField(
            controller: _descriptionController,
            hint: 'Description (Optional)',
            icon: const Icon(Icons.description, color: Colors.white70),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          _buildNutritionSection(),
          const SizedBox(height: 30),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _buildMealTypeOption(MealType.breakfast, 'Breakfast', Icons.breakfast_dining),
          _buildMealTypeOption(MealType.lunch, 'Lunch', Icons.lunch_dining),
          _buildMealTypeOption(MealType.dinner, 'Dinner', Icons.dinner_dining),
          _buildMealTypeOption(MealType.snacks, 'Snack', Icons.apple),
        ],
      ),
    );
  }

  Widget _buildMealTypeOption(MealType value, String label, IconData icon) {
    final isSelected = selectedMealType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMealType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? kGradientStart : Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? kGradientStart : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        CustomField(
          controller: _caloriesController,
          hint: 'Calories',
          icon: const Icon(Icons.local_fire_department, color: Colors.white70),
          inputType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال السعرات الحرارية';
            }
            if (double.tryParse(value) == null) {
              return 'قيمة غير صالحة';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        CustomField(
          controller: _proteinsController,
          hint: 'Proteins (g)',
          icon: const Icon(Icons.egg, color: Colors.white70),
          inputType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال البروتينات';
            }
            if (double.tryParse(value) == null) {
              return 'قيمة غير صالحة';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        CustomField(
          controller: _carbsController,
          hint: 'Carbs (g)',
          icon: const Icon(Icons.rice_bowl, color: Colors.white70),
          inputType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال الكربوهيدرات';
            }
            if (double.tryParse(value) == null) {
              return 'قيمة غير صالحة';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        CustomField(
          controller: _fatsController,
          hint: 'Fats (g)',
          icon: const Icon(Icons.oil_barrel, color: Colors.white70),
          inputType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال الدهون';
            }
            if (double.tryParse(value) == null) {
              return 'قيمة غير صالحة';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveMeal,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.mealToEdit == null ? 'Add Meal' : 'Save Changes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
} 