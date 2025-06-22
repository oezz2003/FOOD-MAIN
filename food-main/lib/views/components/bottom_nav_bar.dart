import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/navigator.dart';
import 'package:healthy_food/views/screens/cart_screen.dart';
import 'package:healthy_food/views/screens/home_screen.dart';
import 'package:healthy_food/views/screens/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xFF0C373A)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              navigator(context: context, screen: HomeScreen());
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30,
                ),
                Text(
                  "Home",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              navigator(context: context, screen: CartScreen());
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                Text(
                  "Cart",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              navigator(context: context, screen: ProfileScreen());
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                Text(
                  "Account",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
