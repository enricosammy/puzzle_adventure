import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../config/flavor_config.dart'; // Updated import path
import '../utils/image.dart'; // Import the ImageSlicer class
import 'puzzle_widget.dart'; // Import the PuzzleWidget class
import 'puzzle_grid.dart'; // Import the PuzzleGrid class
import '../screens/completed_images.dart'; // Import the CompletedImagesScreen

class PuzzleWidgetState extends State<PuzzleWidget> {
  late List<int> tiles;
  late int gridWidth;
  late int gridHeight;
  Timer? _timer;
  int _seconds = 0;
  bool _hasStarted = false;
  int _correctTiles = 0;
  int _steps = 0;
  int _completedLevel = 0;
  List<String> _imagePaths = [];
  late String _selectedImagePath;
  List<ui.Image>? _slicedImages; // Change from late to nullable
  bool _puzzleCompleted = false;
  bool _isLoading = true; // Add loading state
  List<String> _completedImages = []; // List to store completed images
  String? _errorMessage; // Define the _errorMessage variable

  @override
  void initState() {
    super.initState();
    _setGridDimensions(widget.difficulty);
    tiles = _generateTiles(); // Initialize tiles here
    _selectedImagePath = ''; // Initialize with an empty string
    _loadCompletedImages();
    _loadImagePaths().then((_) {
      _loadSelectedImagePath(); // Load the saved image path or a new one
    });
  }

  void _setGridDimensions(String difficulty) {
    switch (difficulty) {
      case 'easy':
        gridWidth = 3;
        gridHeight = 4;
        break;
      case 'medium':
        gridWidth = 4;
        gridHeight = 5;
        break;
      case 'hard':
        gridWidth = 5;
        gridHeight = 6;
        break;
      case 'harder':
        gridWidth = 6;
        gridHeight = 8;
        break;
      case 'insane':
        gridWidth = 7;
        gridHeight = 9;
        break;
      default:
        gridWidth = 4;
        gridHeight = 5;
    }
  }

  Future<void> _loadCompletedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final flavorName = FlavorConfig.instance!.flavor.name;
    final key = '${flavorName}_completedImages';
    setState(() {
      _completedImages = prefs.getStringList(key) ?? [];
    });
  }

  Future<void> _saveCompletedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final flavorName = FlavorConfig.instance!.flavor.name;
    final key = '${flavorName}_completedImages';
    await prefs.setStringList(key, _completedImages);
  }

  Future<void> _loadImagePaths() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final flavorName = FlavorConfig.instance!.flavor.name;
      final flavorDir = Directory('${directory.path}/$flavorName/puzzle');

      developer.log('Loading puzzle images from: ${flavorDir.path}',
          name: 'PuzzleWidget');

      if (!await flavorDir.exists()) {
        setState(() {
          _errorMessage =
              'No puzzle images found for ${FlavorConfig.instance!.appTitle}';
          _isLoading = false;
        });
        return;
      }

      final imageFiles = await flavorDir
          .list()
          .where((entity) =>
              entity is File && entity.path.toLowerCase().endsWith('.png'))
          .map((entity) => entity.path)
          .toList();

      if (imageFiles.isEmpty) {
        setState(() {
          _errorMessage = 'No puzzle images found';
          _isLoading = false;
        });
        return;
      }

      developer.log('Found ${imageFiles.length} puzzle images',
          name: 'PuzzleWidget');

      setState(() {
        _imagePaths = imageFiles;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      developer.log('Error loading puzzle images: $e',
          name: 'PuzzleWidget', error: e);
      setState(() {
        _errorMessage = 'Error loading puzzle images: $e';
        _isLoading = false;
      });
    }
  }

  void _loadNewImage() {
    tiles = _generateTiles();
    _correctTiles = _countCorrectTiles();

    // Filter out completed images and the current image (if it is not empty)
    List<String> availableImages = _imagePaths
        .where((imagePath) =>
            !_completedImages.contains(imagePath) &&
            (imagePath != _selectedImagePath || _selectedImagePath.isEmpty))
        .toList();

    // If all images are completed, reset the pool of available images
    if (availableImages.isEmpty) {
      availableImages = _imagePaths;
      _completedImages.clear(); // Clear the completed images list
      _saveCompletedImages(); // Save the cleared list
    }

    // Select a random image from the available images
    _selectedImagePath =
        availableImages[Random().nextInt(availableImages.length)];

    // Save the selected image path
    _saveSelectedImagePath();

    // Slice the selected image into tiles
    _sliceSelectedImage();
  }

  List<int> _generateTiles() {
    List<int> tiles =
        List.generate(gridWidth * gridHeight - 1, (index) => index + 1)
          ..add(0)
          ..shuffle();
    return tiles;
  }

  void _moveTile(int index) {
    if (!_hasStarted) {
      _startTimer();
      _hasStarted = true;
    }

    int emptyIndex = tiles.indexOf(0);
    int row = index ~/ gridWidth;
    int col = index % gridWidth;
    int emptyRow = emptyIndex ~/ gridWidth;
    int emptyCol = emptyIndex % gridWidth;

    if ((row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 0;
        _correctTiles = _countCorrectTiles();
        _steps++;
        if (_correctTiles == tiles.length - 1) {
          _completedLevel++;
          _puzzleCompleted = true;
          _completedImages
              .add(_selectedImagePath); // Add completed image to the list
          _saveCompletedImages(); // Save the completed images list
          _timer?.cancel();
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _shuffleTiles() {
    setState(() {
      tiles.shuffle();
      _resetTimer();
      _correctTiles = _countCorrectTiles();
      _steps = 0;
      _puzzleCompleted = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _seconds = 0;
    _hasStarted = false;
  }

  int _countCorrectTiles() {
    int correct = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] == i + 1) {
        correct++;
      }
    }
    return correct;
  }

  Future<void> _sliceSelectedImage() async {
    setState(() => _isLoading = true);
    try {
      ImageSlicer slicer = ImageSlicer();
      final slicedImages = await slicer.sliceImage(
        context,
        _selectedImagePath,
        gridWidth,
        gridHeight,
      );

      setState(() {
        _slicedImages = slicedImages;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error slicing image: $e', name: 'PuzzleWidget', error: e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error slicing image: $e';
      });
    }
  }

  Future<void> _saveSelectedImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final flavorName = FlavorConfig.instance!.flavor.name;
    final key = '${flavorName}_selectedImagePath';
    await prefs.setString(key, _selectedImagePath);
  }

  Future<void> _loadSelectedImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final flavorName = FlavorConfig.instance!.flavor.name;
    final key = '${flavorName}_selectedImagePath';
    final savedImagePath = prefs.getString(key);

    if (savedImagePath != null &&
        _imagePaths.contains(savedImagePath) &&
        !_completedImages.contains(savedImagePath)) {
      _selectedImagePath = savedImagePath;
      _sliceSelectedImage();
    } else {
      _loadNewImage(); // Load a new image if the saved image is invalid
    }
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_isLoading || _slicedImages == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/infos.jpg'),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: const Color(0xFFF5F5DC),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.timer, color: Colors.white),
                        Text(
                          'Time\n${_formatTime(_seconds)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.white),
                        Text(
                          'Moves\n$_steps',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.grid_on, color: Colors.white),
                        Text(
                          'Tiles\n${gridWidth}x$gridHeight',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        Text(
                          'Solved\n$_correctTiles/${tiles.length - 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _puzzleCompleted
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _puzzleCompleted = false;
                      _loadNewImage();
                    });
                  },
                  child: Image.file(
                    File(_selectedImagePath),
                    fit: BoxFit.cover,
                  ),
                )
              : PuzzleGrid(
                  tiles: tiles,
                  gridWidth: gridWidth,
                  gridHeight: gridHeight,
                  slicedImages: _slicedImages!,
                  onTap: _moveTile,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _shuffleTiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B4924),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                shadowColor: const Color.fromRGBO(181, 125, 82, 1),
                elevation: 0,
                side: const BorderSide(
                  color: Color.fromRGBO(181, 125, 82, 1),
                  width: 3,
                ),
              ),
              child: const Text(
                'Shuffle',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompletedImagesScreen(
                      completedImages: _completedImages,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B4924),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                shadowColor: const Color.fromRGBO(181, 125, 82, 1),
                elevation: 0,
                side: const BorderSide(
                  color: Color.fromRGBO(181, 125, 82, 1),
                  width: 3,
                ),
              ),
              child: const Text(
                'Show Completed Images',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
