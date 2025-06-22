import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthy_food/config/margin.dart';
import 'package:healthy_food/config/navigator.dart';
import 'package:healthy_food/main.dart';
import 'package:healthy_food/views/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSuccessDialog(BuildContext context, {required String title, required String message, required String buttonText, required Widget icon}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: icon,
              ),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[900],
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  navigator(context: context, screen: HomeScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void signupDialog(BuildContext context) {
  showSuccessDialog(
    context,
    title: "مرحباً بك!",
    message: "تم إنشاء حسابك بنجاح",
    buttonText: "انتقل إلى الرئيسية",
    icon: Icon(
      Icons.check_circle,
      color: Colors.purple[700],
      size: 50,
    ),
  );
}

void passwordResetDialog(BuildContext context) {
  showSuccessDialog(
    context,
    title: "تم تغيير كلمة المرور",
    message: "تم تغيير كلمة المرور الخاصة بك بنجاح",
    buttonText: "انتقل إلى الرئيسية",
    icon: Icon(
      Icons.lock_reset,
      color: Colors.purple[700],
      size: 50,
    ),
  );
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier(false);
  final ValueNotifier<bool> _isConfirmPasswordVisible = ValueNotifier(false);

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await cred.user!.updateDisplayName(_nameController.text.trim());
      await FirebaseAuth.instance.currentUser!.reload();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text.trim());
      await prefs.setString('email', _emailController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      signupDialog(context);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage ?? "Signup failed")),
      );
    } catch (_) {
      _errorMessage = 'An unexpected error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your name' : null,
              ),
              10.h,
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your email' : null,
              ),
              10.h,
              ValueListenableBuilder<bool>(
                valueListenable: _isPasswordVisible,
                builder: (context, isVisible, _) {
                  return TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => _isPasswordVisible.value = !isVisible,
                      ),
                    ),
                    obscureText: !isVisible,
                    validator: (val) => val == null || val.length < 6
                        ? 'Min 6 characters'
                        : null,
                  );
                },
              ),
              10.h,
              ValueListenableBuilder<bool>(
                valueListenable: _isConfirmPasswordVisible,
                builder: (context, isVisible, _) {
                  return TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            _isConfirmPasswordVisible.value = !isVisible,
                      ),
                    ),
                    obscureText: !isVisible,
                    validator: (val) => val != _passwordController.text
                        ? "Passwords don't match"
                        : null,
                  );
                },
              ),
              20.h,
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signUp,
                      child: Text('Sign Up'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}