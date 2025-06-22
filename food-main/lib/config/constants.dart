import 'package:flutter/material.dart';

// Screen Dimensions Extension
extension ScreenSize on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomBarHeight => MediaQuery.of(this).padding.bottom;
  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;
  Size get size => MediaQuery.of(this).size;
}

// App Theme Colors
const Color kPrimaryColor = Color(0xFF166A71);
const Color kSecondaryColor = Color(0xFF757575);
const Color kAccentColor = Color(0xFFFF9800);
const Color kBackgroundColor = Color(0xFFFFFFFF);
const Color kSurfaceColor = Color(0xFFF5F5F5);

// Gradient Colors (White Theme)
const Color kGradientStart = Color(0xFFFFFFFF);
const Color kGradientMiddle = Color(0xFFF8F9FA);
const Color kGradientEnd = Color(0xFFF5F5F5);

// Text Colors
const Color kTextPrimaryColor = Color(0xFF000000);
const Color kTextSecondaryColor = Color(0xFF757575);

// Component Colors
const Color kCardBackgroundColor = Color(0xFFFFFFFF);
const Color kDividerColor = Color(0xFFE0E0E0);
const Color kShadowColor = Color(0x1A000000);

// Status Colors
const Color kSuccessColor = Color(0xFF4CAF50);
const Color kErrorColor = Color(0xFFB00020);
const Color kWarningColor = Color(0xFFFFA726);
const Color kInfoColor = Color(0xFF2196F3);

// Padding and Margin
const double kDefaultPadding = 20.0;
const double kDefaultMargin = 20.0;
const double kDefaultRadius = 15.0;

// Typography
const double kHeadingFontSize = 24.0;
const double kBodyFontSize = 16.0;
const double kCaptionFontSize = 14.0;

// Animation Durations
const Duration kDefaultDuration = Duration(milliseconds: 300);
const Duration kSlowDuration = Duration(milliseconds: 500);
const Duration kFastDuration = Duration(milliseconds: 200);

// Box Shadows
List<BoxShadow> boxShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.4),
    spreadRadius: 2,
    blurRadius: 5,
    offset: Offset(0, 0),
  )
];

// Screen Padding
const double kScreenPadding = 20.0;

// Border Radius
const double kBorderRadius = 15.0;

// Button Sizes
const double kButtonHeight = 50.0;
const double kButtonWidth = 200.0;

// Text Field Heights
const double kTextFieldHeight = 55.0;

// Button Styles
final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: kPrimaryColor,
  foregroundColor: Colors.white,
  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
);