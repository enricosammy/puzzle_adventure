//lib/config/flavor_config.dart
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

enum FlavorType { cartoons, pets, women }

class FlavorConfig {
  final FlavorType flavor;
  static FlavorConfig? instance;

  factory FlavorConfig({required FlavorType flavor}) {
    developer.log('Creating FlavorConfig for flavor: ${flavor.name}',
        name: 'FlavorConfig');
    instance = FlavorConfig._internal(flavor);
    return instance!;
  }

  FlavorConfig._internal(this.flavor);

  static String get assetPath =>
      'assets/puzzle_images/${instance!.flavor.name}/';

  String get appTitle {
    switch (flavor) {
      case FlavorType.cartoons:
        return 'Cartoon Puzzles';
      case FlavorType.pets:
        return 'Pet Puzzles';
      case FlavorType.women:
        return 'Women Puzzles';
    }
  }

  String get appLabel {
    switch (flavor) {
      case FlavorType.cartoons:
        return 'Cartoon\nPuzzle';
      case FlavorType.pets:
        return 'Pet\nPuzzle';
      case FlavorType.women:
        return 'Women\nPuzzle';
    }
  }

  String get logoPath => 'assets/puzzle_images/${flavor.name}/imgs/logo.png';
  String get backgroundPath =>
      'assets/puzzle_images/${flavor.name}/imgs/background.png';

  static void reset() {
    developer.log('Resetting FlavorConfig', name: 'FlavorConfig');
    instance = null;
  }
}
