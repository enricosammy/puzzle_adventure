import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';

final customButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF7B4924),
  minimumSize: const Size(double.infinity, 50),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50),
  ),
  shadowColor: const Color.fromRGBO(181, 125, 82, 1),
  elevation: 0,
  side: const BorderSide(
    color: Color.fromRGBO(181, 125, 82, 1),
    width: 3,
  ),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
);

final buttonTextStyle = const TextStyle(
  color: Color.fromRGBO(211, 144, 94, 1),
  fontSize: 20,
  fontWeight: FontWeight.bold,
  fontFamily: 'Arial',
  shadows: [
    Shadow(
      color: Colors.black, // Choose the color of the shadow
      blurRadius: 0.5, // Adjust the blur radius for the shadow effect
      offset: Offset(
          2.0, 2.0), // Set the horizontal and vertical offset for the shadow
    ),
  ],
);

final buttonContainerDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(50),
  boxShadow: const [
    BoxShadow(
      color: Color.fromRGBO(181, 125, 82, 0.3),
      spreadRadius: 1,
      blurRadius: 5,
      offset: Offset(0, 3),
    ),
  ],
);
