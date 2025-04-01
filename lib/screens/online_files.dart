import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OnlineFilesScreen extends StatefulWidget {
  const OnlineFilesScreen({super.key});

  @override
  State<OnlineFilesScreen> createState() => _OnlineFilesScreenState();
}

class _OnlineFilesScreenState extends State<OnlineFilesScreen> {
  final List<dynamic> _filesAndFolders = [];
  String? _errorMessage;
  bool _isDownloading = false; // Tracking download state
  double _downloadProgress = 0.0; // Progress indicator

  static const flavor =
      String.fromEnvironment('flavor', defaultValue: 'default');

  @override
  void initState() {
    super.initState();
    _loadFilesAndFolders();
  }

  Future<void> _loadFilesAndFolders() async {
    try {
      final apiUrl =
          '${dotenv.env['GITHUB_API_BASE_URL']}/repos/${dotenv.env['GITHUB_REPO_OWNER']}/${dotenv.env['GITHUB_REPO_NAME']}/contents/puzzle_flavors/$flavor';
      final token = dotenv.env['GITHUB_API_TOKEN'];

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _filesAndFolders.addAll(data);
          _errorMessage = data.isEmpty
              ? 'No files or folders found in the "$flavor" folder.'
              : null;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch files: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files and folders: $e')),
      );
    }
  }

  Future<void> _downloadImages() async {
    try {
      setState(() {
        _isDownloading = true; // Enable download state
        _downloadProgress = 0.0; // Reset progress
      });

      final directory = await getApplicationDocumentsDirectory();
      final flavorDir = Directory('${directory.path}/$flavor/puzzle');
      if (!await flavorDir.exists()) {
        await flavorDir.create(recursive: true);
      }

      final apiUrl =
          '${dotenv.env['GITHUB_API_BASE_URL']}/repos/${dotenv.env['GITHUB_REPO_OWNER']}/${dotenv.env['GITHUB_REPO_NAME']}/contents/puzzle_flavors/$flavor';
      final token = dotenv.env['GITHUB_API_TOKEN'];
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        for (var i = 0; i < data.length; i++) {
          final file = data[i];
          if (file['type'] == 'file' && file['download_url'] != null) {
            final imageResponse =
                await http.get(Uri.parse(file['download_url'] as String));
            final fileName = file['name'] as String;
            final localFile = File('${flavorDir.path}/$fileName');
            await localFile.writeAsBytes(imageResponse.bodyBytes);

            setState(() {
              _downloadProgress = (i + 1) / data.length; // Update progress
            });
          }
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Images downloaded successfully!')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch files: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading images: $e')),
      );
    } finally {
      setState(() {
        _isDownloading = false; // Reset download state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the path based on the flavor
    final String backgroundImagePath =
        'assets/puzzle_images/$flavor/imgs/download_background.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Files'),
      ),
      body: Stack(
        children: [
          // Show background and progress bar during download
          if (_isDownloading) ...[
            Positioned.fill(
              child: Image.asset(
                backgroundImagePath, // Load based on flavor
                fit: BoxFit.cover, // Cover the entire screen
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Downloading...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 10),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(1)}% completed',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Default content when not downloading
          if (!_isDownloading)
            Column(
              children: [
                if (_errorMessage != null)
                  Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filesAndFolders.length,
                    itemBuilder: (context, index) {
                      final entity = _filesAndFolders[index];
                      final isDirectory = entity['type'] == 'dir';
                      return ListTile(
                        leading: Icon(isDirectory
                            ? Icons.folder
                            : Icons.insert_drive_file),
                        title: Text(entity['name'] as String,
                            style: const TextStyle(fontSize: 16)),
                        onTap: () {
                          debugPrint('Tapped: ${entity['path']}');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadImages,
        tooltip: 'Download Images',
        child: const Icon(Icons.download),
      ),
    );
  }
}
