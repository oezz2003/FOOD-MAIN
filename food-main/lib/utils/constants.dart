import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFFFFFFFF);

final List<BoxShadow> boxShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.1),
    spreadRadius: 2,
    blurRadius: 5,
    offset: Offset(0, 2),
  ),
];

final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.orange,
  foregroundColor: Colors.white,
  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
); 