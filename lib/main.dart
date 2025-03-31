import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/screens/online_files.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("ENV LOADED: ${dotenv.env['GITHUB_API_BASE_URL']}"); // Debugging line
  } catch (e) {
    print("Failed to load .env: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Adventure',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OnlineFilesScreen(),
    );
  }
}
