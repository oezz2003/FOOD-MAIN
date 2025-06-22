import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthy_food/config/routes.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  late TabController _tabController;
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _logoRotation;
  late Animation<double> _logoScale;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

   
    _logoAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _logoRotation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.elasticOut),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.elasticOut),
    );

   
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

   
    _slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideAnimationController, curve: Curves.easeOutCubic));

    
    _logoAnimationController.forward();
    _fadeAnimationController.forward();
    _slideAnimationController.forward();

    
    _logoAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) _logoAnimationController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) _logoAnimationController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateSignup() {
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your name');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your email');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your password');
      return false;
    }
    if (confirmPasswordController.text.trim().isEmpty) {
      _showErrorSnackBar('Please confirm your password');
      return false;
    }
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showErrorSnackBar('Passwords do not match');
      return false;
    }
    if (passwordController.text.trim().length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  bool _validateLogin() {
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your email');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your password');
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> signup() async {
    if (!_validateSignup()) return;
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await userCredential.user!.updateDisplayName(nameController.text.trim());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _showSuccessSnackBar('Account created successfully!');
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'Registration failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> login() async {
    if (!_validateLogin()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _showSuccessSnackBar('Welcome back!');
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'Login failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade800,
              Colors.white, 
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedBuilder(
                            animation: _logoAnimationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _logoRotation.value,
                                child: Transform.scale(
                                  scale: _logoScale.value,
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      size: 60,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Text(
                                "HealthyBite",
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.green.withOpacity(0.3),
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Nourish Your Body, Feed Your Soul",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(maxWidth: 400),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Column(
                                children: [
                                
                                  Container(
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: TabBar(
                                      controller: _tabController,
                                      indicator: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      dividerColor: Colors.transparent,
                                      labelColor: Colors.green.shade900,
                                      unselectedLabelColor:
                                          Colors.black.withOpacity(0.6),
                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      unselectedLabelStyle: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                      onTap: (index) {
                                        _clearFields();
                                      },
                                      tabs: [
                                        Tab(
                                          child: Container(
                                            padding:
                                                EdgeInsets.symmetric(vertical: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.login,
                                                    size: 18,
                                                    color: Colors.green.shade900),
                                                SizedBox(width: 8),
                                                Text('Login',
                                                    style: TextStyle(
                                                        color: Colors.green
                                                            .shade900)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Tab(
                                          child: Container(
                                            padding:
                                                EdgeInsets.symmetric(vertical: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.person_add,
                                                    size: 18,
                                                    color: Colors.green.shade900),
                                                SizedBox(width: 8),
                                                Text('Sign Up',
                                                    style: TextStyle(
                                                        color: Colors.green
                                                            .shade900)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                 
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    height:
                                        _tabController.index == 0 ? 280 : 420,
                                    padding: EdgeInsets.all(24),
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        // Login Tab
                                        _buildAuthForm(
                                          isLogin: true,
                                          buttonText: "Login",
                                          onPressed: login,
                                          buttonColor: Colors.green.shade900,
                                        ),
                                        // Sign Up Tab
                                        _buildAuthForm(
                                          isLogin: false,
                                          buttonText: "Create Account",
                                          onPressed: signup,
                                          buttonColor: Colors.green.shade900,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm({
    required bool isLogin,
    required String buttonText,
    required VoidCallback onPressed,
    required Color buttonColor,
  }) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          if (!isLogin) ...[
            _buildAnimatedTextField(
              controller: nameController,
              label: "Full Name",
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              delay: 100,
            ),
            SizedBox(height: 16),
          ],
          _buildAnimatedTextField(
            controller: emailController,
            label: "Email Address",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            delay: isLogin ? 100 : 200,
          ),
          SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscure,
            onToggleVisibility: () =>
                setState(() => _obscure = !_obscure),
            delay: isLogin ? 200 : 300,
          ),
          if (!isLogin) ...[
            SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: confirmPasswordController,
              label: "Confirm Password",
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureConfirm,
              onToggleVisibility: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              delay: 400,
            ),
          ],
          SizedBox(height: 32),
          // Animated Action Button
          TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: _isLoading
                      ? Container(
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.green.shade900,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade800,
                                Colors.green.shade300
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: onPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              buttonText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleVisibility,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText ?? false,
                style: TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: Colors.green.shade900.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon,
                        color: Colors.green.shade900.withOpacity(0.7), size: 20),
                  ),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            (obscureText ?? false)
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.green.shade900.withOpacity(0.7),
                            size: 22,
                          ),
                          onPressed: onToggleVisibility,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}