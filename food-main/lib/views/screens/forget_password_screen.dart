import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/margin.dart';

import 'package:healthy_food/views/components/custom_text_field.dart';

import '../../main.dart';
import '../dialogs/signup_dialog.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Image.asset("assets/images/bg.png"),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(20),
              width: context.screenWidth,
              height:   context.screenHeight,
              decoration: BoxDecoration(
                  boxShadow: boxShadow,
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, Color(0xFFDDE1E1)],
                    stops: [0, 1],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )),
              child: PageView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forget Password?",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      20.h,
                      Text(
                        "Hello there!",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      20.h,
                      Text(
                        "Enter your email address. We will send a code verification in the next step.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      20.h,
                      Text(
                        "Email Address",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      5.h,
                      CustomField(
                        controller: TextEditingController(),
                        icon: Icon(Icons.mail),
                        hint: "example@example.com",
                      ),
                      40.h,
                      InkWell(
                        onTap: (){
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: Text("Continue",style: TextStyle(
                              color: Colors.white,fontWeight: FontWeight.bold
                          ),),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forget Password?",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      40.h,
                      Text(
                        "You’ve got mail",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      30.h,
                      Text(
                        "We will send you the verification code to your email address, check your email and put the code right below.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      30.h,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomField(
                            width: 60,
                            textAlign: TextAlign.center,
                            inputType: TextInputType.number,
                            controller: TextEditingController(),
                          ),
                          CustomField(
                            width: 60,
                            textAlign: TextAlign.center,
                            inputType: TextInputType.number,
                            controller: TextEditingController(),
                          ),
                          CustomField(
                            width: 60,
                            textAlign: TextAlign.center,
                            inputType: TextInputType.number,
                            controller: TextEditingController(),
                          ),
                          CustomField(
                            width: 60,
                            textAlign: TextAlign.center,
                            inputType: TextInputType.number,
                            controller: TextEditingController(),
                          ),
                          CustomField(
                            width: 60,
                            textAlign: TextAlign.center,
                            inputType: TextInputType.number,
                            controller: TextEditingController(),
                          ),
                        ],
                      ),
                      50.h,
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: context.screenWidth / 1.5,
                          child: Text(
                            "Didn’t receive the mail? You can resend it in 49 sec",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      40.h,
                      InkWell(
                        onTap: (){
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: Text("Continue",style: TextStyle(
                              color: Colors.white,fontWeight: FontWeight.bold
                          ),),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create a new password",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      20.h,
                      Text(
                        "Enter your new password. If you forgot it then you have to do the step of forgot password..",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      20.h,
                      Text(
                        "New Password",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      5.h,
                      CustomField(
                        controller: TextEditingController(),
                        secure: true,
                      ),
                      20.h,
                      Text(
                        "Confirm Password",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      5.h,
                      CustomField(
                        controller: TextEditingController(),
                        secure: true,
                      ),
                      40.h,
                      InkWell(
                        onTap: (){
                          passwordResetDialog(context);
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: Text("Continue",style: TextStyle(
                              color: Colors.white,fontWeight: FontWeight.bold
                          ),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
