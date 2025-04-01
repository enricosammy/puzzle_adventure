import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class OnlineFilesScreen extends StatefulWidget {
  const OnlineFilesScreen({super.key});

  @override
  State<OnlineFilesScreen> createState() => _OnlineFilesScreenState();
}

class _OnlineFilesScreenState extends State<OnlineFilesScreen> {
  final List<dynamic> _filesAndFolders = [];
  String? _errorMessage;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  static const String flavor =
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
        setState(() {
          _errorMessage = 'Failed to fetch files: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading files and folders: $e';
      });
    }
  }

  Future<void> _downloadImages() async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
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
              _downloadProgress = (i + 1) / data.length;
            });
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Images downloaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch files: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading images: $e')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String backgroundImagePath =
        'assets/puzzle_images/$flavor/imgs/download_background.png';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 40);
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'Online Files',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox();
              },
            ),
          ),
          if (_isDownloading)
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
            )
          else if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            )
          else
            GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _filesAndFolders.length,
              itemBuilder: (context, index) {
                final entity = _filesAndFolders[index];
                return GestureDetector(
                  onTap: () {
                    debugPrint('Tapped: ${entity['path']}');
                  },
                  child: Container(
                    color: Colors.white.withOpacity(0.2),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            entity['type'] == 'dir'
                                ? Icons.folder
                                : Icons.insert_drive_file,
                            color: Colors.white,
                          ),
                          Text(
                            entity['name'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
