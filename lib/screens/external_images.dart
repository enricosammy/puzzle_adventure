import 'package:flutter/material.dart';
import 'dart:io';
import '../config/flavor_config.dart';
import 'package:path_provider/path_provider.dart';

class ExternalImagesScreen extends StatefulWidget {
  const ExternalImagesScreen({super.key});

  @override
  State<ExternalImagesScreen> createState() => _ExternalImagesScreenState();
}

class _ExternalImagesScreenState extends State<ExternalImagesScreen> {
  List<File> _images = [];
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

      debugPrint('Found ${imageFiles.length} puzzle images');

      setState(() {
        _images = imageFiles;
        _errorMessage = imageFiles.isEmpty ? 'No puzzle images found' : null;
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
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
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
            const Text(
              'External Images',
              style: TextStyle(color: Colors.white), // Set text color to white
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
            padding: EdgeInsets.only(top: statusBarHeight + kToolbarHeight),
            child: _errorMessage != null
                ? Center(
                    child: Text(_errorMessage!,
                        style: const TextStyle(color: Colors.white)))
                : _images.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: const EdgeInsets.all(0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image:
                                                      FileImage(_images[index]),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.file(
                                    _images[index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    _images[index].path,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
