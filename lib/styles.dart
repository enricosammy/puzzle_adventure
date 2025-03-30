import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';

final customButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF7B4924),
  minimumSize: const Size(double.infinity, 60),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50),
  ),
  shadowColor: const Color.fromRGBO(181, 125, 82, 1),
  elevation: 0,
  side: const BorderSide(
    color: Color.fromRGBO(181, 125, 82, 1),
    width: 3,
  ),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
);

final buttonTextStyle = const TextStyle(
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.bold,
  fontFamily: 'Petrona',
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
