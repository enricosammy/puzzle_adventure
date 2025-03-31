import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles.dart'; // Import the styles.dart file
import '../config/flavor_config.dart'; // Add this import
import 'puzzle_screen.dart'; // Import the PuzzleScreen
import 'external_images.dart'; // Import the ExternalImagesScreen
import 'completed_images.dart'; // Add this import
import 'online_files.dart'; // Import the OnlineFilesScreen

class HomeScreen extends StatelessWidget {
  final List<String> imagePaths;

  const HomeScreen({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              FlavorConfig.instance!.logoPath,
              height: 40,
              semanticLabel: 'App Logo',
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading logo: $error');
                return Image.asset(
                  'assets/logo.png',
                  height: 40,
                  semanticLabel: 'Default Logo',
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              FlavorConfig.instance!.appTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor:
            Colors.transparent, // Make AppBar background transparent
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white), // Set icon color to white
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              FlavorConfig.instance!.backgroundPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/background.jpg', fit: BoxFit.cover);
              },
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(
                48, statusBarHeight + kToolbarHeight, 48, 48),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: buttonContainerDecoration,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PuzzleScreen(
                              difficulty: 'easy',
                              imagePaths: imagePaths,
                            ),
                          ),
                        );
                      },
                      style: customButtonStyle,
                      child: Text(
                        'Start Easy Puzzle',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: buttonContainerDecoration,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PuzzleScreen(
                              difficulty: 'medium',
                              imagePaths: imagePaths,
                            ),
                          ),
                        );
                      },
                      style: customButtonStyle,
                      child: Text(
                        'Start Medium Puzzle',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: buttonContainerDecoration,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PuzzleScreen(
                              difficulty: 'hard',
                              imagePaths: imagePaths,
                            ),
                          ),
                        );
                      },
                      style: customButtonStyle,
                      child: Text(
                        'Start Hard Puzzle',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: buttonContainerDecoration,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PuzzleScreen(
                              difficulty: 'harder',
                              imagePaths: imagePaths,
                            ),
                          ),
                        );
                      },
                      style: customButtonStyle,
                      child: Text(
                        'Start Harder Puzzle',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: buttonContainerDecoration,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PuzzleScreen(
                              difficulty: 'insane',
                              imagePaths: imagePaths,
                            ),
                          ),
                        );
                      },
                      style: customButtonStyle,
                      child: Text(
                        'Start Insane Puzzle',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: buttonContainerDecoration,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExternalImagesScreen(),
                          ),
                        );
                      },
                      style: customButtonStyle,
                      child: Text(
                        'External Images',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: buttonContainerDecoration,
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final completedImages =
                            prefs.getStringList('completedImages') ?? [];
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompletedImagesScreen(
                                completedImages: completedImages,
                              ),
                            ),
                          );
                        }
                      },
                      style: customButtonStyle,
                      child: Text(
                        'Completed Images',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  // Online Files Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: buttonContainerDecoration,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnlineFilesScreen(),
                          ),
                        );
                      },
                      style: customButtonStyle,
                      child: Text(
                        'Online Files',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
