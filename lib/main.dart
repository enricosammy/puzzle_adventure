import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'config/flavor_config.dart';
import 'utils/copy_assets.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Fetch the flavor name from environment variables
  const String flavorName =
      String.fromEnvironment('flavor', defaultValue: 'cartoons');
  developer.log('Initializing flavor: $flavorName', name: 'Main');

  // Match the flavor with the enum values or default to FlavorType.cartoons
  final flavorType = FlavorType.values.firstWhere(
    (f) => f.name == flavorName,
    orElse: () => FlavorType.cartoons,
  );

  // Initialize the FlavorConfig singleton with the selected flavor
  FlavorConfig(flavor: flavorType);

  // Copy assets and retrieve their paths
  final List<String> imagePaths =
      await copyAssetsToInternalStorage(FlavorConfig.assetPath);
  developer.log('Copied ${imagePaths.length} images', name: 'Main');

  // Run the app
  runApp(MyApp(imagePaths: imagePaths));
}

class MyApp extends StatelessWidget {
  final List<String> imagePaths;

  const MyApp({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    final config = FlavorConfig.instance!;
    return MaterialApp(
      title: config.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(imagePaths: imagePaths), // Starting with HomeScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
