import 'package:flutter/material.dart';
import 'dart:io';

class OnlineFilesScreen extends StatefulWidget {
  const OnlineFilesScreen({super.key});

  @override
  State<OnlineFilesScreen> createState() => _OnlineFilesScreenState();
}

class _OnlineFilesScreenState extends State<OnlineFilesScreen> {
  List<FileSystemEntity> _filesAndFolders = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFilesAndFolders();
  }

  Future<void> _loadFilesAndFolders() async {
    try {
      final directory =
          Directory('puzzle_flavors'); // Updated path to parent folder
      if (directory.existsSync()) {
        final entities = directory
            .listSync(); // List all files and folders in puzzle_flavors

        setState(() {
          _filesAndFolders = entities;
          _errorMessage = entities.isEmpty
              ? 'No files or folders found in puzzle_flavors.'
              : null;
        });
      } else {
        setState(() {
          _errorMessage = 'Directory does not exist: puzzle_flavors.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading files and folders: $e';
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
              child: Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            )
          : ListView.builder(
              itemCount: _filesAndFolders.length,
              itemBuilder: (context, index) {
                final entity = _filesAndFolders[index];
                final isDirectory =
                    FileSystemEntity.isDirectorySync(entity.path);
                return ListTile(
                  leading: Icon(
                      isDirectory ? Icons.folder : Icons.insert_drive_file),
                  title: Text(
                    entity.path.split(Platform.pathSeparator).last,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    // Placeholder for actions when clicking on a file/folder
                    debugPrint('Tapped: ${entity.path}');
                  },
                );
              },
            ),
    );
  }
}
