import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final CollectionReference cartItems =
      FirebaseFirestore.instance.collection('cartItems');

  static addToCart(Map<String, dynamic> item) async {
    final DocumentReference docRef = FirebaseFirestore.instance
        .collection('cartItems')
        .doc(); 
    await docRef.set({
      ...item,
      'quantity': 1,
    });
  }

  static removeFromCart(String itemId) async {
    await FirebaseFirestore.instance.collection('cartItems').doc(itemId).delete();
  }

  static updateQuantity(String itemId, int newQuantity) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('cartItems').doc(itemId);

    if (newQuantity <= 0) {
      docRef.delete();
    } else {
      await docRef.update({'quantity': newQuantity});
    }
  }

  static clearCart() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('cartItems').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static double get totalAmount {
    double total = 0.0;
    // هذا يعتمد على استرجاع البيانات في مكان آخر
    return total;
  }

  static int get itemCount {
    // عدد العناصر في السلة
    return 0;
  }
}