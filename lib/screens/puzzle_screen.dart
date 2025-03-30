import 'package:flutter/material.dart';
import '../widgets/puzzle_widget.dart';
import '../styles.dart';
import '../config/flavor_config.dart';

class PuzzleScreen extends StatelessWidget {
  final String difficulty;
  final List<String> imagePaths;

  const PuzzleScreen({
    super.key,
    required this.difficulty,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final String title =
        '${difficulty[0].toUpperCase()}${difficulty.substring(1)} Puzzle';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              FlavorConfig.instance!.logoPath,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/logo.png', height: 40);
              },
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          // Loading overlay
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: imagePaths.isEmpty
                  ? Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Loading ${FlavorConfig.instance!.appTitle}...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // Puzzle widget
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight + kToolbarHeight),
            child: PuzzleWidget(
              difficulty: difficulty,
              imagePaths: imagePaths,
            ),
          ),
        ],
      ),
    );
  }
}
