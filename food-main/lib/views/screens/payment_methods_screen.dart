import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/margin.dart';
import 'package:healthy_food/views/screens/profile_screen.dart';
import '../../config/navigator.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SizedBox(
        width: context.screenWidth,
        child: Column(
          children: [
            40.h,
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  navigator(context: context, screen: ProfileScreen());
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 40),
                width: context.screenWidth / 1.15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, -5),
                    )
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      30.h,
                      Text(
                        "Payment Methods",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Credit Cards",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.h,
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 30),
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      20.h,
                      _buildPaymentCard(
                        context,
                        image: "visa",
                        cardNumber: "4086 •••• •••• 9709",
                        isDefault: true,
                        color: Color(0xFFE8F0FD),
                      ),
                      15.h,
                      _buildPaymentCard(
                        context,
                        image: "master",
                        cardNumber: "5486 •••• •••• 1234",
                        isDefault: false,
                        color: Color(0xFFF8F9FA),
                      ),
                      40.h,
                      _buildAddCardButton(context),
                      // 30.h, // This was removed because the logos are no longer needed.
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 20),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       Image.asset("assets/images/visa_logo.png", width: 60),
                      //       Image.asset("assets/images/mastercard_logo.png", width: 60),
                      //       // Image.asset("assets/images/paypal_logo.png", width: 60),
                      //     ],
                      //   ),
                      // ),
                      // 30.h, // This was removed because the logos are no longer needed.
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context, {
    required String image,
    required String cardNumber,
    required bool isDefault,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: isDefault
            ? Border.all(color: kPrimaryColor, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Image.asset("assets/images/$image.png", width: 40),
          15.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cardNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (isDefault)
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      5.w,
                      Text(
                        "Default Payment",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // يمكنك هنا توجيه المستخدم إلى صفحة إضافة بطاقة جديدة
        navigator(context: context, screen: ProfileScreen());
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.2),
              blurRadius: 10,
            )
          ],
        ),
        child: Text(
          "+ Add New Card",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}