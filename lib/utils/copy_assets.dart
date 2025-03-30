import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/flavor_config.dart';

Future<List<String>> copyAssetsToInternalStorage(String flavorPath) async {
  try {
    debugPrint('Copying assets for flavor path: $flavorPath');
    final String manifestContent =
        await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap =
        json.decode(manifestContent) as Map<String, dynamic>;

    final directory = await getApplicationDocumentsDirectory();
    final flavorName = FlavorConfig.instance!.flavor.name;
    final flavorDir = Directory('${directory.path}/$flavorName/puzzle');

    debugPrint('Creating puzzle directory: ${flavorDir.path}');
    if (!await flavorDir.exists()) {
      await flavorDir.create(recursive: true);
    }

    final assetPaths = manifestMap.keys
        .where((String key) =>
            key.startsWith(flavorPath) && key.contains('/puzzle/'))
        .toList();

    debugPrint('Found ${assetPaths.length} puzzle assets to copy');
    List<String> copiedImagePaths = [];

    for (String assetPath in assetPaths) {
      final byteData = await rootBundle.load(assetPath);
      final fileName = assetPath.split('/').last;
      final File file = File('${flavorDir.path}/$fileName');

      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
      copiedImagePaths.add(file.path);
      debugPrint('Copied puzzle image: ${file.path}');
    }

    return copiedImagePaths;
  } catch (e) {
    debugPrint('Error copying puzzle assets: $e');
    return [];
  }
}
