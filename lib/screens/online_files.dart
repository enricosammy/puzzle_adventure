import 'package:path_provider/path_provider.dart';

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
      final directory = Directory.current;
      final entities = directory.listSync();

      setState(() {
        _filesAndFolders = entities;
        _errorMessage = entities.isEmpty ? 'No files or folders found.' : null;
      });
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
          ? Center(child: Text(_errorMessage!))
          : ListView.builder(
              itemCount: _filesAndFolders.length,
              itemBuilder: (context, index) {
                final entity = _filesAndFolders[index];
                final isDirectory =
                    FileSystemEntity.isDirectorySync(entity.path);
                return ListTile(
                  leading: Icon(
                      isDirectory ? Icons.folder : Icons.insert_drive_file),
                  title: Text(entity.path.split(Platform.pathSeparator).last),
                );
              },
            ),
    );
  }
}
