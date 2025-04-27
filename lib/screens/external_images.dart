import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui'; // Import for blur effects
import '../config/flavor_config.dart';
import 'package:path_provider/path_provider.dart';

class ExternalImagesScreen extends StatefulWidget {
  const ExternalImagesScreen({super.key});

  @override
  State<ExternalImagesScreen> createState() => _ExternalImagesScreenState();
}

class _ExternalImagesScreenState extends State<ExternalImagesScreen> {
  List<File> _images = [];
  List<String> completedImages = []; // List to store completed image filenames
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final flavorName = FlavorConfig.instance!.flavor.name;
      final flavorDir = Directory('${directory.path}/$flavorName/puzzle');

      debugPrint('Loading puzzle images from: ${flavorDir.path}');

      if (!await flavorDir.exists()) {
        setState(() {
          _errorMessage =
              'No puzzle images found for ${FlavorConfig.instance!.appTitle}';
        });
        return;
      }

      final imageFiles = await flavorDir
          .list()
          .where((entity) =>
              entity is File && entity.path.toLowerCase().endsWith('.png'))
          .map((e) => File(e.path))
          .toList();

      final validImageFiles = imageFiles.where((file) {
        final fileName = file.path.split('/').last.split('.').first;
        return int.tryParse(fileName) != null;
      }).toList();

      validImageFiles.sort((a, b) {
        final aName = int.parse(a.path.split('/').last.split('.').first);
        final bName = int.parse(b.path.split('/').last.split('.').first);
        return aName.compareTo(bName);
      });

      debugPrint(
          'Valid and sorted images: ${validImageFiles.map((e) => e.path).toList()}');

      // Simulate completed images (for testing, replace with actual logic)
      completedImages = ['1', '3', '5']; // Example of completed image filenames

      setState(() {
        _images = validImageFiles;
        _errorMessage =
            validImageFiles.isEmpty ? 'No valid puzzle images found' : null;
      });
    } catch (e) {
      debugPrint('Error loading puzzle images: $e');
      setState(() {
        _errorMessage = 'Error loading puzzle images: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              FlavorConfig.instance!.logoPath,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 40);
              },
            ),
            const SizedBox(width: 10),
            const Text('External Images',
                style: TextStyle(color: Colors.white)),
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
          // Main content
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight + kToolbarHeight),
            child: _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : _images.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          final filePath = _images[index].path;
                          final fileName =
                              filePath.split('/').last.split('.').first;

                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(0),
                                    child: Image.file(_images[index],
                                        fit: BoxFit.cover),
                                  );
                                },
                              );
                            },
                            child: Stack(
                              children: [
                                Image.file(
                                  _images[index],
                                  fit: BoxFit.cover,
                                ),
                                // Apply blur if the image is not completed
                                if (!completedImages.contains(fileName))
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 1, sigmaY: 1),
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
