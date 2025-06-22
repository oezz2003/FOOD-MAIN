import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen>
    with TickerProviderStateMixin {
  String searchFilter = '';
  String statusFilter = 'all';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;


  final Color primaryBlue = const Color(0xFF2563EB);
  final Color darkBlue = const Color(0xFF1E40AF);
  final Color lightBlue = const Color(0xFFDBEAFE);
  final Color accentCyan = const Color(0xFF06B6D4);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningAmber = const Color(0xFFF59E0B);
  final Color errorRed = const Color(0xFFEF4444);
  final Color neutralGray = const Color(0xFF6B7280);
  final Color lightGray = const Color(0xFFF9FAFB);
  final Color whiteCard = Colors.white;
  final Color darkText = const Color(0xFF111827);
  final Color mediumText = const Color(0xFF4B5563);
  final Color lightText = const Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Orders',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryBlue, darkBlue],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () => setState(() {}),
              ),
              const SizedBox(width: 8),
            ],
          ),


          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: whiteCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.search_rounded,
                              color: primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Search & Filter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),


                    Container(
                      decoration: BoxDecoration(
                        color: lightGray,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by product name...',
                          hintStyle: TextStyle(color: lightText),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: neutralGray),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchFilter = value.toLowerCase();
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),


                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all', Icons.list_alt_rounded),
                          const SizedBox(width: 12),
                          _buildFilterChip('Confirmed', 'confirmed', Icons.check_circle_rounded),
                          const SizedBox(width: 12),
                          _buildFilterChip('Pending', 'pending', Icons.schedule_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('email', isEqualTo: userEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final orders = snapshot.data!.docs;
                final totalOrders = orders.length;
                final confirmedOrders = orders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'confirmed';
                }).length;
                final pendingOrders = totalOrders - confirmedOrders;

                return Container(
                  height: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Orders',
                          totalOrders.toString(),
                          Icons.shopping_bag_rounded,
                          [primaryBlue, darkBlue],
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: _buildStatCard(
                          'Confirmed',
                          confirmedOrders.toString(),
                          Icons.check_circle_rounded,
                          [successGreen, const Color(0xFF059669)],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          pendingOrders.toString(),
                          Icons.schedule_rounded,
                          [warningAmber, const Color(0xFFD97706)],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),


          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('email', isEqualTo: userEmail)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              final filteredOrders = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;


                final products = data['products'] as List<dynamic>? ?? [];
                final productNames = products.map((p) =>
                    (p['name'] ?? '').toString().toLowerCase()).join(' ');

                final searchMatch = searchFilter.isEmpty ||
                    productNames.contains(searchFilter);

                final status = data['status'] ?? 'pending';
                final statusMatch = statusFilter == 'all' || status == statusFilter;

                return searchMatch && statusMatch;
              }).toList();

              if (filteredOrders.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: lightGray,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: lightText,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: mediumText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your orders will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final doc = filteredOrders[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildOrderCard(context, doc.id, data);
                  },
                  childCount: filteredOrders.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : lightGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : mediumText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : mediumText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withOpacity(0.1),
            gradientColors[1].withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: gradientColors[0].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: gradientColors[0], size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: gradientColors[0],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: mediumText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String docId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final products = data['products'] as List<dynamic>? ?? [];

    double totalPrice = 0.0;
    if (products.isNotEmpty) {
      for (var product in products) {
        final price = product['price'] ?? 0;
        final quantity = product['quantity'] ?? 1;
        totalPrice += (price as num) * (quantity as num);
      }
    }

    String formattedDate = 'No date';
    if (data['timestamp'] != null) {
      final date = (data['timestamp'] as Timestamp).toDate();
      formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: whiteCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: status == 'confirmed'
              ? successGreen.withOpacity(0.3)
              : warningAmber.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showOrderDetails(context, docId, data),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [lightBlue, lightBlue.withOpacity(0.5)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${docId.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: lightText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == 'confirmed'
                            ? successGreen.withOpacity(0.1)
                            : warningAmber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'confirmed'
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                            size: 14,
                            color: status == 'confirmed' ? successGreen : warningAmber,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: status == 'confirmed' ? successGreen : warningAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),


                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2_rounded,
                              color: primaryBlue, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${products.length} Product${products.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...products.take(2).map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: whiteCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: product['image'] != null
                                    ? Image.network(
                                  product['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image_rounded,
                                          color: lightText, size: 20),
                                )
                                    : Icon(Icons.image_rounded,
                                    color: lightText, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Unknown Product',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Qty: ${product['quantity']} • ${product['price']} LE',
                                    style: TextStyle(
                                      color: mediumText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      if (products.length > 2)
                        Text(
                          '+${products.length - 2} more items',
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [successGreen.withOpacity(0.1),
                              successGreen.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payments_rounded,
                                color: successGreen, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Total: $totalPrice LE',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.rate_review_rounded,
                            color: accentCyan, size: 20),
                        onPressed: () => _showReviewDialog(context, docId, data),
                        tooltip: 'Add Review',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, String orderId, Map<String, dynamic> data) {
    final products = data['products'] as List<dynamic>? ?? [];
    double totalPrice = 0.0;
    if (products.isNotEmpty) {
      for (var product in products) {
        final price = product['price'] ?? 0;
        final quantity = product['quantity'] ?? 1;
        totalPrice += (price as num) * (quantity as num);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.receipt_long_rounded,
                                color: primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Order Details',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Order #${orderId.substring(0, 8).toUpperCase()}',
                                  style: TextStyle(
                                    color: mediumText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer Information',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.person_rounded,
                                    color: primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                Text(data['name'] ?? 'Unknown'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email_rounded,
                                    color: primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                Text(data['email'] ?? 'No email'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),


                      const Text(
                        'Ordered Products',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...(data['products'] as List<dynamic>? ?? []).map((product) =>
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: whiteCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: lightGray,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: product['image'] != null
                                        ? Image.network(
                                      product['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.image_rounded,
                                              color: lightText, size: 24),
                                    )
                                        : Icon(Icons.image_rounded,
                                        color: lightText, size: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? 'Unknown Product',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quantity: ${product['quantity']}',
                                        style: TextStyle(
                                          color: mediumText,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product['price']} LE',
                                        style: TextStyle(
                                          color: successGreen,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ).toList(),

                      const SizedBox(height: 20),


                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [successGreen.withOpacity(0.1),
                              successGreen.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: successGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$totalPrice LE',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, String orderId, Map<String, dynamic> orderData) {
    final products = orderData['products'] as List<dynamic>? ?? [];
    double totalPrice = 0.0;
    if (products.isNotEmpty) {
      for (var product in products) {
        final price = product['price'] ?? 0;
        final quantity = product['quantity'] ?? 1;
        totalPrice += (price as num) * (quantity as num);
      }
    }

    final TextEditingController reviewController = TextEditingController();
    double rating = 5.0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 16,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: whiteCard,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accentCyan.withOpacity(0.2), accentCyan.withOpacity(0.1)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.rate_review_rounded,
                                color: accentCyan,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rate Your Experience',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Order #${orderId.substring(0, 8).toUpperCase()}',
                                    style: TextStyle(
                                      color: lightText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: isSubmitting ? null : () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: lightText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),


                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: lightGray,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.shopping_bag_rounded, color: primaryBlue, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Order Summary',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${(orderData['products'] as List).length} items • $totalPrice LE',
                                style: TextStyle(
                                  color: mediumText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),


                        const Text(
                          'How would you rate this order?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: isSubmitting ? null : () {
                                      setState(() {
                                        rating = index + 1.0;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.star_rounded,
                                        size: 36,
                                        color: index < rating
                                            ? warningAmber
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getRatingText(rating),
                                style: TextStyle(
                                  color: _getRatingColor(rating),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Share your experience (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: lightGray,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: reviewController,
                            enabled: !isSubmitting,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Tell us about your experience with this order...',
                              hintStyle: TextStyle(color: lightText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),


                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: mediumText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: isSubmitting ? null : () async {
                                  setState(() {
                                    isSubmitting = true;
                                  });

                                  try {
                                    await _submitReview(orderId, rating, reviewController.text.trim());

                                    if (mounted) {
                                      Navigator.pop(context);
                                      _showSuccessSnackBar(context);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      _showErrorSnackBar(context, e.toString());
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentCyan,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : const Text(
                                  'Submit Review',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate this order';
    }
  }

  Color _getRatingColor(double rating) {
    switch (rating.toInt()) {
      case 1:
      case 2:
        return errorRed;
      case 3:
        return warningAmber;
      case 4:
      case 5:
        return successGreen;
      default:
        return lightText;
    }
  }

  Future<void> _submitReview(String orderId, double rating, String reviewText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};
    final userName = userData['name'] ?? user.displayName ?? 'Anonymous';

    await FirebaseFirestore.instance.collection('reviews').add({
      'orderId': orderId,
      'userId': user.uid,
      'userEmail': user.email,
      'userName': userName,
      'rating': rating,
      'review': reviewText.isEmpty ? null : reviewText,
      'timestamp': FieldValue.serverTimestamp(),
      'helpful': 0,
      'reported': false,
    });

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'hasReview': true,
      'reviewSubmittedAt': FieldValue.serverTimestamp(),
    });
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'Review submitted successfully!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error: $error',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showOrderReviews(BuildContext context, String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: whiteCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.rate_review_rounded,
                        color: primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Reviews',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Customer feedback and ratings',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .where('orderId', isEqualTo: orderId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: lightGray,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: lightText,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No reviews yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: mediumText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to review this order',
                              style: TextStyle(
                                color: lightText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final review = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return _buildReviewCard(review);
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

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] ?? 0.0).toDouble();
    final reviewText = review['review'] ?? '';
    final userName = review['userName'] ?? 'Anonymous';
    final timestamp = review['timestamp'] as Timestamp?;

    String formattedDate = 'Recently';
    if (timestamp != null) {
      final date = timestamp.toDate();
      formattedDate = DateFormat('MMM d, yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Row(
      children: [
      Container(
      width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, accentCyan],
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      userName,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
    const SizedBox(height: 4),
    Row(
    children: [
    ...List.generate(5, (index) => Icon(
    Icons.star_rounded,
    size: 16,
    color: index < rating ? warningAmber : Colors.grey.shade300,
    )),
    const SizedBox(width: 8),
    Text(
    formattedDate,
    style: TextStyle(
      color: lightText,
      fontSize: 12,
    ),
    ),
    ],
    ),
      ],
      ),
      ),
      ],
      ),

          if (reviewText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteCard,
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: Text(
                reviewText,
                style: TextStyle(
                  color: mediumText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

}