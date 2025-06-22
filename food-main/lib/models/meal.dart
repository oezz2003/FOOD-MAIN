import 'package:cloud_firestore/cloud_firestore.dart';

// نموذج الوجبة
class Meal {
  final String id;
  final String userId;
  final String name;
  final String description;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final String imageUrl;
  final DateTime dateTime;
  final String date;
  final String time;
  final MealType type;

  Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.imageUrl,
    required this.dateTime,
    required this.date,
    required this.time,
    required this.type, required int protein,
  });

  // إنشاء Meal من Firestore
  factory Meal.fromFirestore(DocumentSnapshot doc, DateTime parse, {required String userId}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Meal(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      proteins: (data['proteins'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fats: (data['fats'] ?? 0).toDouble(),
      imageUrl: data['photoURL'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      type: MealType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MealType.breakfast,
      ), protein: 20,
    );
  }

  // تحويل Meal إلى Map للحفظ في Firestore (يمكن استخدامها كـ toMap)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'photoURL': imageUrl,
      'dateTime': Timestamp.fromDate(dateTime),
      'date': date,
      'time': time,
      'type': type.name,
    };
  }

  Map<String, dynamic> toMap() {
    return toFirestore(); // استخدام toFirestore كدالة toMap
  }
}

// نموذج عنصر القائمة
class MenuItem {
  final String id;
  final String category;
  final String description;
  final List<String> ingredientsList;
  final DateTime createdAt;

  MenuItem({
    required this.id,
    required this.category,
    required this.description,
    required this.ingredientsList,
    required this.createdAt,
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // تحويل ingredientsList من Firebase
    List<String> ingredients = [];
    if (data['ingredientsList'] is List) {
      for (var ingredient in data['ingredientsList']) {
        if (ingredient is Map<String, dynamic>) {
          ingredients.add(ingredient['name'] ?? '');
        }
      }
    }
    
    return MenuItem(
      id: doc.id,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      ingredientsList: ingredients,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'description': description,
      'ingredientsList': ingredientsList.map((ingredient) => {
        'name': ingredient,
      }).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// نموذج عنصر المخزون
class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final String barcode;
  final double costPerUnit;
  final String location;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final List<String> menuItems;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.barcode,
    required this.costPerUnit,
    required this.location,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.createdAt,
    required this.menuItems,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // تحويل menuItems من Firebase
    List<String> items = [];
    if (data['menuItems'] is List) {
      for (var item in data['menuItems']) {
        if (item is Map<String, dynamic>) {
          items.add(item['name'] ?? '');
        }
      }
    }
    
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      barcode: data['barcode'] ?? '',
      costPerUnit: (data['costPerUnit'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      expiryDate: data['expiryDate'] != null 
          ? DateTime.parse(data['expiryDate'])
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      menuItems: items,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'barcode': barcode,
      'costPerUnit': costPerUnit,
      'location': location,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate?.toIso8601String(),
      'createdAt': Timestamp.fromDate(createdAt),
      'menuItems': menuItems.map((item) => {
        'name': item,
      }).toList(),
    };
  }
}

// نوع الوجبة
enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks,
}