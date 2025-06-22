import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:intl/intl.dart';
import 'cart_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String emailFilter = '';
  String statusFilter = 'all';
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // فحص دور المستخدم (أدمن أم مستخدم عادي)
  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // فحص إذا كان المستخدم موجود في مجموعة الأدمن
        final adminDoc = await FirebaseFirestore.instance
            .collection('Admins')
            .doc(user.uid)
            .get();
        
        setState(() {
          isAdmin = adminDoc.exists;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isAdmin = false;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isAdmin = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartScreen()),
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.shopping_cart, color: Color(0xFF673AB7)),
      ),
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        Text(
                          "Orders",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isAdmin ? "Admin Panel" : "My Orders",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => setState(() {}),
                    ),
                  ],
                ),
              ),

              // Filters (للأدمن فقط)
              if (isAdmin) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Filter Orders",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Filter by email",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              emailFilter = value.trim().toLowerCase();
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            SizedBox(width: 8),
                            _buildFilterChip('Confirmed', 'confirmed'),
                            SizedBox(width: 8),
                            _buildFilterChip('Pending', 'pending'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Stats Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getOrdersStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    final allOrders = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();

                    final pendingCount = allOrders
                        .where((data) =>
                            !data.containsKey('status') ||
                            data['status'] == 'pending')
                        .length;
                    final confirmedCount = allOrders
                        .where((data) =>
                            data.containsKey('status') &&
                            data['status'] == 'confirmed')
                        .length;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildCountCard(
                            title: "Total Orders",
                            count: allOrders.length,
                            icon: Icons.shopping_cart,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildCountCard(
                            title: "Pending",
                            count: pendingCount,
                            icon: Icons.pending_actions,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildCountCard(
                            title: "Confirmed",
                            count: confirmedCount,
                            icon: Icons.check_circle,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Orders List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getOrdersStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    final filteredOrders = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      
                      // للأدمن: تطبيق الفلاتر
                      if (isAdmin) {
                        final email = (data['email'] ?? '').toLowerCase();
                        final status =
                            (data.containsKey('status') ? data['status'] : 'pending')
                                .toLowerCase();

                        final emailMatch = email.contains(emailFilter);
                        final statusMatch =
                            statusFilter == 'all' || status == statusFilter;

                        return emailMatch && statusMatch;
                      }
                      
                      // للمستخدم العادي: عرض طلباته فقط
                      return true;
                    }).toList();

                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.white.withOpacity(0.5)),
                            SizedBox(height: 16),
                            Text(
                              isAdmin ? "No matching orders found" : "No orders yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            if (!isAdmin) ...[
                              SizedBox(height: 8),
                              Text(
                                "Start ordering delicious meals!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final doc = filteredOrders[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;
                        final status =
                            data.containsKey('status') ? data['status'] : 'pending';

                        String formattedDate = "No time";
                        if (data['timestamp'] != null) {
                          final date = (data['timestamp'] as Timestamp).toDate();
                          formattedDate =
                              DateFormat('MMM d, yyyy - h:mm a').format(date);
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: status == 'confirmed'
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] ?? '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          // عرض الإيميل للأدمن فقط
                                          if (isAdmin) ...[
                                            Text(
                                              data['email'] ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                          ] else ...[
                                            SizedBox(height: 8),
                                          ],
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _buildInfoChip(
                                                data['product'] ?? '',
                                                Colors.purple,
                                              ),
                                              _buildInfoChip(
                                                "Qty: ${data['quantity'] ?? ''}",
                                                Colors.blue,
                                              ),
                                              _buildInfoChip(
                                                "${data['price'] ?? ''} LE",
                                                Colors.green,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: status == 'confirmed'
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.orange.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                status == 'confirmed'
                                                    ? Icons.check_circle
                                                    : Icons.pending,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        // أزرار التحكم للأدمن فقط
                                        if (isAdmin) ...[
                                          Row(
                                            children: [
                                              if (status != 'confirmed')
                                                IconButton(
                                                  icon: Icon(Icons.check_circle),
                                                  color: Colors.green,
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection('orders')
                                                        .doc(docId)
                                                        .update({'status': 'confirmed'});
                                                  },
                                                ),
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                color: Colors.red.withOpacity(0.7),
                                                onPressed: () {
                                                  _showDeleteDialog(docId);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(color: Colors.white.withOpacity(0.2)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // إنشاء Stream للطلبات حسب دور المستخدم
  Stream<QuerySnapshot> _getOrdersStream() {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    
    if (isAdmin) {
      // الأدمن يرى جميع الطلبات
      return FirebaseFirestore.instance
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      // المستخدم العادي يرى طلباته فقط
      return FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF7E57C2),
        title: Text(
          "Delete Order",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete this order?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('orders')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = statusFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          statusFilter = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCountCard({
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}