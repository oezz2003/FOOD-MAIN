import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:healthy_food/models/cart_service.dart';
import 'package:healthy_food/views/screens/cart_screen.dart';


class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> menuItem;

  const DetailsScreen({Key? key, required this.menuItem, required String heroTag}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with TickerProviderStateMixin {
  bool isFavorite = false;
  int quantity = 1;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  List<Map<String, dynamic>> additionalItems = [
    {
      "name": "Pepper julienned", 
      "price": 2.30, 
      "selected": false,
      "image": "https://images.unsplash.com/photo-1594756202469-9cb1424f8cbd?w=100&h=100&fit=crop"
    },
    {
      "name": "Baby spinach", 
      "price": 2.30, 
      "selected": false,
      "image": "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=100&h=100&fit=crop"
    },
    {
      "name": "Mushroom", 
      "price": 2.30, 
      "selected": false,
      "image": "https://images.unsplash.com/photo-1518375677071-8d2729cdbe36?w=100&h=100&fit=crop"
    },
  ];

  List<Map<String, dynamic>> relatedItems = [
    {
      "name": "Chicken Nolos",
      "price": 5.99,
      "image": "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=200&h=200&fit=crop",
      "color": Colors.pink[50]
    },
    {
      "name": "Chow Fun",
      "price": 5.99,
      "image": "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=200&h=200&fit=crop",
      "color": Colors.orange[50]
    },
    {
      "name": "Chicken BBQ",
      "price": 5.99,
      "image": "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200&h=200&fit=crop",
      "color": Colors.blue[50]
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  double get totalPrice {
    double basePrice = widget.menuItem['price'] * quantity;
    double addOnsPrice = additionalItems
        .where((item) => item['selected'])
        .fold(0.0, (sum, item) => sum + item['price']);
    return basePrice + addOnsPrice;
  }

  void _addToCart() async {
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    List<String> selectedAddOns = additionalItems
        .where((item) => item['selected'])
        .map((item) => item['name'] as String)
        .toList();

    Map<String, dynamic> cartItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': widget.menuItem['name'],
      'price': widget.menuItem['price'],
      'image': widget.menuItem['image'],
      'quantity': quantity,
      'addOns': selectedAddOns,
      'addOnsPrice': additionalItems
          .where((item) => item['selected'])
          .fold(0.0, (sum, item) => sum + item['price']),
      'totalPrice': totalPrice,
    };

    await CartService.addToCart(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('تم إضافة ${widget.menuItem['name']} إلى السلة'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFavorite),
                      color: isFavorite ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.menuItem['name'],
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.menuItem['image'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price Section
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.menuItem['name'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '\$${widget.menuItem['price'].toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        // Quantity Selector
                        Row(
                          children: [
                            Text(
                              'الكمية: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: quantity > 1 ? () {
                                      setState(() {
                                        quantity--;
                                      });
                                    } : null,
                                    icon: Icon(Icons.remove, size: 18),
                                    padding: EdgeInsets.all(8),
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        quantity++;
                                      });
                                    },
                                    icon: Icon(Icons.add, size: 18),
                                    padding: EdgeInsets.all(8),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Add More Items Section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add more items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        ...additionalItems.map((item) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: item['selected'] ? Colors.green : Colors.grey[200]!,
                                width: item['selected'] ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '+\$${item['price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: item['selected'] ? Colors.green : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      color: item['selected'] ? Colors.green : Colors.transparent,
                                    ),
                                    child: item['selected'] 
                                        ? Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  additionalItems[additionalItems.indexOf(item)]['selected'] = 
                                      !item['selected'];
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Related Items Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Related Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 180,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: relatedItems.length,
                      itemBuilder: (context, index) {
                        final item = relatedItems[index];
                        return Container(
                          width: 140,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: item['color'],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: item['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${item['price'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Description Section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.menuItem['description'] ?? 'If this product is sold by Amazon, please review the product description and ingredients carefully.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // تقليل المساحة
  decoration: BoxDecoration(
    color: Colors.green, // اللون الأخضر للـ bottom bar
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, -2),
      ),
    ],
  ),
  child: SafeArea(
    child: AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonAnimation.value,
          child: Container(
            width: double.infinity,
            height: 40, 
            child: InkWell(
              onTap: () {
                _addToCart();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blue, size: 24), 
                  SizedBox(width: 8),
                  Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // لون النص
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2), // خلفية السعر
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ),
),
    );
  }
}