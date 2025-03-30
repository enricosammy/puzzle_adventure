import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class MyApp extends StatelessWidget {
  final List<String> imagePaths;

  const MyApp({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Puzzle Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(imagePaths: imagePaths),
    );
  }
}
