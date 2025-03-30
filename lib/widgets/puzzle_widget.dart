import 'package:flutter/material.dart';

import 'puzzle_widget_state.dart'; // Import the PuzzleWidgetState class

class PuzzleWidget extends StatefulWidget {
  final String difficulty;
  final List<String> imagePaths;

  const PuzzleWidget({
    super.key,
    required this.difficulty,
    required this.imagePaths,
  });

  @override
  PuzzleWidgetState createState() => PuzzleWidgetState();
}
