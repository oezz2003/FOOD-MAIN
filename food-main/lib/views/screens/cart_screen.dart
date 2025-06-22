import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatefulWidget {
  static var cart;
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final CollectionReference cartItems =
  FirebaseFirestore.instance.collection('cartItems');
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  double deliveryFee = 2.50; // Delivery fee

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shopping Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: _clearCartDialog,
              child: Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartItems.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            String errorMessage = 'Unknown error occurred';
            if (snapshot.error.toString().contains('permission-denied')) {
              errorMessage = 'You do not have permission to access the data';
            } else if (snapshot.error.toString().contains('unavailable')) {
              errorMessage = 'Service is currently unavailable';
            } else if (snapshot.error.toString().contains('not-found')) {
              errorMessage = 'The requested data was not found';
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Connection Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          final items = snapshot.data?.docs ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cart is Empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Add some items to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView(
            children: [
              ...items.map((doc) {
                final item = doc.data() as Map<String, dynamic>;
                final String name = item['name'] ?? 'Unknown';
                final double price = item['price']?.toDouble() ?? 0.0;
                int quantity = item['quantity'] ?? 1;
                final String image = item['image'] ?? '';
                return Card(
                  margin:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.image),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.fastfood, size: 30),
                        ),
                      ),
                    ),
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${price.toStringAsFixed(2)}'),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () async {
                                try {
                                  if (quantity > 1) {
                                    await doc.reference
                                        .update({'quantity': quantity - 1});
                                  } else {
                                    await doc.reference.delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$name deleted')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Error occurred: ${e.toString()}')),
                                  );
                                }
                              },
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                try {
                                  await doc.reference
                                      .update({'quantity': quantity + 1});
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Error occurred: ${e.toString()}')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: () async {
                        try {
                          await doc.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name deleted')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error occurred: ${e.toString()}')),
                          );
                        }
                      },
                    ),
                  ),
                );
              }).toList(),

              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Number of items (${items.length})'),
                        Text(
                          '\$${_calculateTotalPrice(items).toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery fee'),
                        Text('\$${deliveryFee.toStringAsFixed(2)}'),
                      ],
                    ),
                    Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${(_calculateTotalPrice(items) + deliveryFee).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: items.isNotEmpty ? () => _showCheckoutDialog(context, items) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Proceed to Order',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateTotalPrice(List<QueryDocumentSnapshot> items) {
    double total = 0.0;
    for (var doc in items) {
      final item = doc.data() as Map<String, dynamic>;
      final double price = item['price']?.toDouble() ?? 0.0;
      final int quantity = item['quantity']?.toInt() ?? 1;
      total += price * quantity;
    }
    return total;
  }

  void _clearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cart'),
        content: Text('Are you sure you want to clear the cart?'),
        actions: [
          TextButton(
              onPressed: Navigator.of(context).pop, child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                final snapshot = await cartItems.get();
                for (var doc in snapshot.docs) {
                  await doc.reference.delete();
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Cart cleared')));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error occurred: ${e.toString()}')));
              }
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, List<QueryDocumentSnapshot> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'Confirm Order',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'We will contact you by phone to confirm your order.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total'),
                  Text(
                    '\$${(_calculateTotalPrice(items) + deliveryFee).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    final orderId = await FirebaseFirestore.instance
                        .collection('orders')
                        .add({
                      'email': user?.email ?? '',
                      'name': user?.displayName ?? 'User',
                      'products': items.map((item) => item.data()).toList(),
                      'total_price':
                      _calculateTotalPrice(items) + deliveryFee,
                      'status': 'pending',
                      'timestamp': FieldValue.serverTimestamp(),
                    });


                    for (var doc in items) {
                      await doc.reference.delete();
                    }

                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/orderSummary');
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error occurred: ${e.toString()}')));
                  }
                },
                icon: Icon(Icons.check, color: Colors.white),
                label: Text('Send Order',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}