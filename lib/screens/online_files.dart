import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OnlineFilesScreen extends StatefulWidget {
  const OnlineFilesScreen({super.key});

  @override
  State<OnlineFilesScreen> createState() => _OnlineFilesScreenState();
}

class _OnlineFilesScreenState extends State<OnlineFilesScreen> {
  List<dynamic> _filesAndFolders = [];
  String? _errorMessage;

  // Define the flavor variable with lowercase 'flavor'
  static const flavor =
      String.fromEnvironment('flavor', defaultValue: 'default');

  @override
  void initState() {
    super.initState();
    _loadFilesAndFolders();
  }

  Future<void> _loadFilesAndFolders() async {
    try {
      // Use the lowercase 'flavor' variable to construct the API URL
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
        final data = jsonDecode(response.body);
        setState(() {
          _filesAndFolders = data as List<dynamic>;
          _errorMessage = data.isEmpty
              ? 'No files or folders found in the "$flavor" folder.'
              : null;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch files for flavor "$flavor": ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Error loading files and folders for flavor "$flavor": $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Files'),
      ),
      body: _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _filesAndFolders.length,
              itemBuilder: (context, index) {
                final entity = _filesAndFolders[index];
                final isDirectory = entity['type'] ==
                    'dir'; // GitHub API specifies 'dir' for folders
                return ListTile(
                  leading: Icon(
                      isDirectory ? Icons.folder : Icons.insert_drive_file),
                  title: Text(entity['name'] as String,
                      style: const TextStyle(fontSize: 16)),
                  onTap: () {
                    debugPrint('Tapped: ${entity['path']}');
                  },
                );
              },
            ),
    );
  }
}
