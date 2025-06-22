import 'dart:io';
import 'package:flutter/material.dart';

/// Navigation helper function with different navigation types
Future<void> navigator({
  required BuildContext context,
  required Widget screen,
  bool remove = false,
  bool replacement = false,
  bool pop = false,
}) async {
  try {
    // Check if context is still mounted
    if (!context.mounted) return;
    
    if (remove) {
      // Push and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => screen),
        (Route<dynamic> route) => false,
      );
    } else if (replacement) {
      // Replace current route
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    } else {
      // Normal push (with optional pop)
      if (pop && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  } on SocketException catch (e) {
    // Handle network errors
    debugPrint('Navigation failed due to network error: $e');
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  } catch (e) {
    // Handle other errors
    debugPrint('Navigation failed: $e');
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// Enhanced navigation with custom animations
Future<void> navigatorWithAnimation({
  required BuildContext context,
  required Widget screen,
  bool remove = false,
  bool replacement = false,
  NavigationAnimation animation = NavigationAnimation.slide,
}) async {
  try {
    if (!context.mounted) return;
    
    final route = _buildAnimatedRoute(screen, animation);
    
    if (remove) {
      Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
    } else if (replacement) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  } catch (e) {
    debugPrint('Animated navigation failed: $e');
  }
}

/// Build animated route based on animation type
PageRouteBuilder _buildAnimatedRoute(Widget screen, NavigationAnimation animation) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, anim, secondaryAnimation, child) {
      switch (animation) {
        case NavigationAnimation.slide:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        case NavigationAnimation.fade:
          return FadeTransition(
            opacity: anim,
            child: child,
          );
        case NavigationAnimation.scale:
          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        case NavigationAnimation.slideUp:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
      }
    },
  );
}

/// Navigation animation types
enum NavigationAnimation {
  slide,
  fade,
  scale,
  slideUp,
}

/// Extension for easier navigation
extension NavigationHelper on BuildContext {
  /// Push new screen
  void push(Widget screen) {
    navigator(context: this, screen: screen);
  }
  
  /// Push and replace current screen
  void pushReplacement(Widget screen) {
    navigator(context: this, screen: screen, replacement: true);
  }
  
  /// Push and remove all previous screens
  void pushAndRemoveUntil(Widget screen) {
    navigator(context: this, screen: screen, remove: true);
  }
  
  /// Pop current screen
  void popScreen() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }
  
  /// Push with animation
  void pushWithAnimation(Widget screen, {NavigationAnimation animation = NavigationAnimation.slide}) {
    navigatorWithAnimation(
      context: this,
      screen: screen,
      animation: animation,
    );
  }
}