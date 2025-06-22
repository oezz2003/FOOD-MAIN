import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:healthy_food/models/meal.dart';
import 'package:healthy_food/models/user_goals.dart';
import 'package:healthy_food/models/user_profile.dart' as user_profile;
import 'package:healthy_food/models/meal.dart' as meal_model;
import 'package:healthy_food/models/meal_plan.dart';
import 'package:healthy_food/models/address.dart' as address_model;
import 'package:healthy_food/models/order.dart' as order_model;
import 'package:healthy_food/models/notification.dart' as notification_model;
import 'package:healthy_food/models/meal_review.dart' as meal_review_model;
// يجب أن يكون موجودًا
import 'dart:io';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // الحصول على المستخدم الحالي
  static User? get currentUser => _auth.currentUser;
  static String get userId => _auth.currentUser?.uid ?? '';

  // ==================== Authentication ====================
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw ArgumentError('Required fields cannot be empty');
      }
      if (age <= 0 || weight <= 0 || height <= 0) {
        throw ArgumentError('Age, weight, and height must be positive values');
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _createUserProfile(
        userId: userCredential.user!.uid,
        email: email,
        name: name,
        age: age,
        weight: weight,
        height: height,
        gender: gender,
        activityLevel: activityLevel,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error in signUp: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in signUp: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ArgumentError('Email and password cannot be empty');
      }
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error in signIn: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in signIn: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error in signOut: $e');
      rethrow;
    }
  }

  // ==================== User Profile Management ====================
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String name,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
    String? phoneNumber,
    DateTime? birthday,
    String? imageUrl,
  }) async {
    try {
      double bmr = _calculateBMR(weight, height, age, gender);
      double dailyCalories = _calculateDailyCalories(bmr, activityLevel);

      user_profile.UserProfile userProfile = user_profile.UserProfile(
        userId: userId,
        email: email,
        name: name,
        age: age,
        weight: weight,
        height: height,
        gender: gender,
        activityLevel: activityLevel,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        phoneNumber: phoneNumber,
        birthday: birthday,
        imageUrl: imageUrl,
      );

      await _firestore.collection('users').doc(userId).set(userProfile.toMap());

      UserGoals goals = UserGoals(
        userId: userId,
        dailyCalories: dailyCalories,
        dailyProtein: weight * 1.6,
        dailyCarbs: dailyCalories * 0.5 / 4,
        dailyFats: dailyCalories * 0.25 / 9,
        dailyWater: 2.5,
        dailySteps: 8000,
        dailyExerciseMinutes: 30,
        goalType: 'maintain',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc('daily')
          .set(goals.toMap());
    } on FirebaseException catch (e) {
      print('Firebase Error creating user profile: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<user_profile.UserProfile?> getUserProfile() async {
    try {
      if (userId.isEmpty) return null;
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return user_profile.UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } on FirebaseException catch (e) {
      print('Firebase Error getting user profile: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateWeight(double newWeight) async {
    try {
      if (newWeight <= 0) {
        throw ArgumentError('Weight must be a positive value');
      }
      await _firestore.collection('users').doc(userId).update({
        'weight': newWeight,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weight_history')
          .add({
        'weight': newWeight,
        'date': FieldValue.serverTimestamp(),
      });

      await _updateGoalsAfterWeightChange(newWeight);
    } on FirebaseException catch (e) {
      print('Firebase Error updating weight: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating weight: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    String? name,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activityLevel,
    String? phoneNumber,
    DateTime? birthday,
    String? imagePath,
    String? imageUrl,
    required String userId, required String email,
  }) async {
    try {
      if (userId.isEmpty) throw Exception('No user logged in');

      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (weight != null) updateData['weight'] = weight;
      if (height != null) updateData['height'] = height;
      if (gender != null) updateData['gender'] = gender;
      if (activityLevel != null) updateData['activityLevel'] = activityLevel;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (birthday != null)
        updateData['birthday'] = Timestamp.fromDate(birthday);

      if (imagePath != null && imagePath.isNotEmpty) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef =
            _storage.ref().child('profile_images/$userId/$fileName');
        UploadTask uploadTask = storageRef.putFile(File(imagePath));
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
        updateData['imageUrl'] = imageUrl;
      } else if (imageUrl != null) {
        updateData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('users').doc(userId).update(updateData);
    } on FirebaseException catch (e) {
      print('Firebase Error updating user profile: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  double _calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  double _calculateDailyCalories(double bmr, String activityLevel) {
    double activityFactor = 1.2;
    switch (activityLevel) {
      case 'sedentary':
        activityFactor = 1.2;
        break;
      case 'lightly_active':
        activityFactor = 1.375;
        break;
      case 'moderately_active':
        activityFactor = 1.55;
        break;
      case 'very_active':
        activityFactor = 1.725;
        break;
      case 'extra_active':
        activityFactor = 1.9;
        break;
    }
    return bmr * activityFactor;
  }

  Future<void> _updateGoalsAfterWeightChange(double newWeight) async {
    try {
      if (userId.isEmpty) return;
      DocumentSnapshot goalsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc('daily')
          .get();
      if (goalsDoc.exists && goalsDoc.data() != null) {
        UserGoals currentGoals = UserGoals.fromMap(
          goalsDoc.data() as Map<String, dynamic>,
        );
        double newProtein = newWeight * 1.6;
        UserGoals updatedGoals = currentGoals.copyWith(
          dailyProtein: newProtein,
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .doc('daily')
            .update(updatedGoals.toMap());
      }
    } on FirebaseException catch (e) {
      print(
          'Firebase Error updating goals after weight change: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating goals after weight change: $e');
      rethrow;
    }
  }

  // ==================== Meals Management ====================
  static Stream<List<meal_model.Meal>> getMealsStream() {
    if (userId.isEmpty) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('meals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => meal_model.Meal.fromFirestore(
              doc,
              (doc.data() as Map<String, dynamic>)['dateTime'] is Timestamp
                  ? (doc.data() as Map<String, dynamic>)['dateTime'].toDate()
                  : DateTime.now(),
              userId: (doc.data() as Map<String, dynamic>)['userId'] ?? userId))
          .toList();
    });
  }

  Future<List<meal_model.Meal>> getMealsForDate(DateTime date) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      String dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      QuerySnapshot querySnapshot = await _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: dateString)
          .get();
      return querySnapshot.docs
          .map((doc) => meal_model.Meal.fromFirestore(
              doc,
              (doc.data() as Map<String, dynamic>)['dateTime'] is Timestamp
                  ? (doc.data() as Map<String, dynamic>)['dateTime'].toDate()
                  : DateTime.now(),
              userId: (doc.data() as Map<String, dynamic>)['userId'] ?? userId))
          .toList();
    } catch (e) {
      print('Error getting meals for date: $e');
      rethrow;
    }
  }

  Future<void> addMeal(meal_model.Meal meal) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore.collection('meals').doc(meal.id).set(meal.toMap());
    } on FirebaseException catch (e) {
      print('Firebase Error adding meal: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding meal: $e');
      rethrow;
    }
  }

  Future<void> updateMeal(meal_model.Meal meal) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore.collection('meals').doc(meal.id).update(meal.toMap());
    } on FirebaseException catch (e) {
      print('Firebase Error updating meal: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating meal: $e');
      rethrow;
    }
  }

  Future<void> deleteMeal(String mealId, String date) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore.collection('meals').doc(mealId).delete();
    } on FirebaseException catch (e) {
      print('Firebase Error deleting meal: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error deleting meal: $e');
      rethrow;
    }
  }

  // ==================== Meal Plan Management ====================
  Future<String> addMealPlan(Meal mealPlan) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      DocumentReference planRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .add(mealPlan.toFirestore());
      return planRef.id;
    } on FirebaseException catch (e) {
      print('Firebase Error adding meal plan: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding meal plan: $e');
      rethrow;
    }
  }

  Future<List<Meal>> getMealPlans() async {
    try {
      if (userId.isEmpty) return [];
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .orderBy('createdAt', descending: true)
          .get();
return snapshot.docs
    .map((doc) => Meal.fromFirestore(doc, doc.data() as DateTime, userId: FirebaseService.userId))
    .toList();    } on FirebaseException catch (e) {
      print('Firebase Error getting meal plans: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      print('Error getting meal plans: $e');
      return [];
    }
  }

  // ==================== Orders Management ====================
  Stream<List<order_model.Order>> getUserOrders() {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => order_model.Order.fromFirestore(doc))
            .toList());
  }

  // ==================== Notifications Management ====================
  Stream<List<notification_model.Notification>> getUserNotifications() {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => notification_model.Notification.fromFirestore(doc))
            .toList());
  }

  // ==================== Meal Reviews Management ====================
  Future<void> submitMealReview({
    required String mealId,
    required String comment,
    required double rating,
  }) async {
    try {
      if (userId.isEmpty) throw Exception('No user logged in');
      final userProfile = await getUserProfile();
      if (userProfile == null) throw Exception('User profile not found');
      meal_review_model.MealReview review = meal_review_model.MealReview(
        id: _firestore
            .collection('meals')
            .doc(mealId)
            .collection('reviews')
            .doc()
            .id,
        mealId: mealId,
        userId: userId,
        username: userProfile.name,
        comment: comment,
        rating: rating,
        createdAt: DateTime.now(),
        reviewText: '',
      );
      await _firestore
          .collection('meals')
          .doc(mealId)
          .collection('reviews')
          .add(review.toFirestore());
    } on FirebaseException catch (e) {
      print('Firebase Error submitting meal review: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error submitting meal review: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot?> getMealReviews(String mealId) {
    try {
      return _firestore
          .collection('meals')
          .doc(mealId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } on FirebaseException catch (e) {
      print('Firebase Error getting meal reviews: ${e.code} - ${e.message}');
      return Stream.value(null);
    } catch (e) {
      print('Error getting meal reviews: $e');
      return Stream.value(null);
    }
  }

  // ==================== Address Management ====================
  Future<String?> addAddress(address_model.Address address) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      DocumentReference addressRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add(address.toMap());
      return addressRef.id;
    } on FirebaseException catch (e) {
      print('Firebase Error adding address: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding address: $e');
      rethrow;
    }
  }

  Future<List<address_model.Address>> getUserAddresses() async {
    try {
      if (userId.isEmpty) return [];
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return address_model.Address.fromMap(data, doc.id);
      }).toList();
    } on FirebaseException catch (e) {
      print('Firebase Error getting addresses: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      print('Error getting addresses: $e');
      return [];
    }
  }

  Future<void> updateAddress(
      String addressId, address_model.Address address) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .update(address.toMap());
    } on FirebaseException catch (e) {
      print('Firebase Error updating address: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } on FirebaseException catch (e) {
      print('Firebase Error deleting address: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error deleting address: $e');
      rethrow;
    }
  }

  // ==================== Inventory Management ====================
  Future<void> addInventoryItem(InventoryItem item) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore.collection('inventory').add(item.toFirestore());
    } on FirebaseException catch (e) {
      print('Firebase Error adding inventory item: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding inventory item: $e');
      rethrow;
    }
  }

  Stream<List<InventoryItem>> getInventoryItems() {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('inventory')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore
          .collection('inventory')
          .doc(item.id)
          .update(item.toFirestore());
    } on FirebaseException catch (e) {
      print('Firebase Error updating inventory item: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating inventory item: $e');
      rethrow;
    }
  }

  Future<void> deleteInventoryItem(String itemId) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore.collection('inventory').doc(itemId).delete();
    } on FirebaseException catch (e) {
      print('Firebase Error deleting inventory item: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error deleting inventory item: $e');
      rethrow;
    }
  }

  // ==================== Menu Item Management ====================
  Future<void> addMenuItem(MenuItem item) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore.collection('menu_items').add(item.toFirestore());
    } on FirebaseException catch (e) {
      print('Firebase Error adding menu item: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding menu item: $e');
      rethrow;
    }
  }

  Stream<List<MenuItem>> getMenuItems() {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('menu_items')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateMenuItem(MenuItem item) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore
          .collection('menu_items')
          .doc(item.id)
          .update(item.toFirestore());
    } on FirebaseException catch (e) {
      print('Firebase Error updating menu item: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating menu item: $e');
      rethrow;
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    try {
      if (userId.isEmpty) {
        throw StateError('User not authenticated');
      }
      await _firestore.collection('menu_items').doc(itemId).delete();
    } on FirebaseException catch (e) {
      print('Firebase Error deleting menu item: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error deleting menu item: $e');
      rethrow;
    }
  }

  // ==================== Data Export ====================
  Future<Map<String, dynamic>> exportUserData() async {
    if (userId.isEmpty) {
      throw StateError('User not authenticated');
    }
    Map<String, dynamic> exportData = {};
    user_profile.UserProfile? userProfile = await getUserProfile();
    if (userProfile != null) {
      exportData['userProfile'] = userProfile.toMap();
    }
    UserGoals? goals = await getUserGoals();
    if (goals != null) {
      exportData['userGoals'] = goals.toMap();
    }
    QuerySnapshot weightHistorySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('weight_history')
        .get();
    exportData['weightHistory'] =
        weightHistorySnapshot.docs.map((doc) => doc.data()).toList();
    List<meal_model.Meal> meals = (await getMealsStream().first);
    exportData['meals'] = meals.map((meal) => meal.toMap()).toList();
    List<Meal> mealPlans = await getMealPlans();
    exportData['mealPlans'] =
        mealPlans.map((plan) => plan?.toFirestore()).toList();
    List<address_model.Address> addresses = await getUserAddresses();
    exportData['addresses'] =
        addresses.map((address) => address.toMap()).toList();
    List<InventoryItem> inventoryItems = await getInventoryItems().first;
    exportData['inventoryItems'] =
        inventoryItems.map((item) => item.toFirestore()).toList();
    List<MenuItem> menuItems = await getMenuItems().first;
    exportData['menuItems'] =
        menuItems.map((item) => item.toFirestore()).toList();
    return exportData;
  }

  // ==================== User Goals Management ====================
  Future<UserGoals?> getUserGoals() async {
    try {
      if (userId.isEmpty) return null;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc('daily')
          .get();
      if (doc.exists && doc.data() != null) {
        return UserGoals.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user goals: $e');
      return null;
    }
  }

  Future<void> updateUserGoals(UserGoals goals) async {
    try {
      if (userId.isEmpty) throw Exception('User not authenticated');
      await _firestore.collection('users').doc(userId).set(goals.toMap());
    } catch (e) {
      print('Error updating user goals: $e');
      rethrow;
    }
  }

  uploadImage(String s) {}
}

