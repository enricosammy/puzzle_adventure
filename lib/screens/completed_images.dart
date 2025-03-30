import 'package:flutter/material.dart';
import 'dart:io';
import '../config/flavor_config.dart'; // Add this import

class CompletedImagesScreen extends StatelessWidget {
  final List<String> completedImages;

  const CompletedImagesScreen({super.key, required this.completedImages});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                FlavorConfig.instance!.logoPath,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/logo.png', height: 40);
                },
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Completed Puzzles',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
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
          // Background with parallax effect
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            child: Image.asset(
              FlavorConfig.instance!.backgroundPath,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/background.jpg', fit: BoxFit.cover);
              },
            ),
          ),
          // Grid with completed puzzles
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight + kToolbarHeight),
            child: completedImages.isEmpty
                ? const Center(
                    child: Text(
                      'No completed puzzles yet!\nSolve some puzzles to see them here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemCount: completedImages.length,
                    itemBuilder: (context, index) => _buildGridItem(
                      context,
                      completedImages[index],
                      index,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String imagePath, int index) {
    return Hero(
      tag: 'puzzle_$index',
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showFullScreenImage(context, imagePath, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromRGBO(181, 125, 82, 1),
                width: 4,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Hero(
              tag: 'puzzle_$index',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
