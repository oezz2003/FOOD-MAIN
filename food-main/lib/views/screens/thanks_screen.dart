import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/margin.dart';
import 'package:healthy_food/views/screens/home_screen.dart';

import '../../config/navigator.dart';

class ThanksScreen extends StatelessWidget {
  const ThanksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: InkWell(
          onTap: () {
            navigator(context: context, screen: HomeScreen());
          },
          child: Icon(Icons.close, color: Colors.white, size: 30),
        ),
      ),
      body: SizedBox(
        width: context.screenWidth,
        height: context.screenHeight,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Image.asset(
              "assets/images/thanks.png",
              width: context.screenWidth/1.5,
            ),
            SizedBox(
              width: context.screenWidth,
              child: Column(
                children: [
                  (context.screenHeight/20).h,
                  Image.asset("assets/images/done.png"),
                  10.h,
                  Text(
                    "We're preparing your meal!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40
                    ),
                  ),
                  Text(
                    "Order n° 76890",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                  30.h,
                  Text(
                    "Thanks",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
