import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/routes.dart';


class MealsScreen extends StatelessWidget {
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
              child: Padding(
                padding: EdgeInsets.all(kDefaultPadding),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildMealCategory(
                      context,
                      'Breakfast',
                      'assets/images/egg.png',
                      Colors.orange[100]!,
                      () => Navigator.pushNamed(context, AppRoutes.breakfast),
                    ),
                    _buildMealCategory(
                      context,
                      'Lunch',
                      'assets/images/rice.png',
                      Colors.green[100]!,
                      () => Navigator.pushNamed(context, AppRoutes.lunch),
                    ),
                    _buildMealCategory(
                      context,
                      'Dinner',
                      'assets/images/spageti.png',
                      Colors.blue[100]!,
                      () => Navigator.pushNamed(context, AppRoutes.dinner),
                    ),
                    _buildMealCategory(
                      context,
                      'Snacks',
                      'assets/images/snacks.png',
                      Colors.purple[100]!,
                      () => Navigator.pushNamed(context, AppRoutes.snacks),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              Text(
                'Meals',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Select a meal category',
            style: TextStyle(
              fontSize: kBodyFontSize,
              color: kTextSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCategory(
    BuildContext context,
    String title,
    String imagePath,
    Color backgroundColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(kDefaultRadius),
          boxShadow: [
            BoxShadow(
              color: kShadowColor,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 64,
              width: 64,
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: kBodyFontSize,
                fontWeight: FontWeight.bold,
                color: kTextPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 