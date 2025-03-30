import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data'; // Add this import for Uint8List

class ImageSlicer {
  Future<List<ui.Image>> sliceImage(BuildContext context, String imagePath,
      int gridWidth, int gridHeight) async {
    final File imageFile = File(imagePath);
    final Uint8List imageData = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageData);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final List<ui.Image> slices = [];
    final double sliceWidth = image.width / gridWidth;
    final double sliceHeight = image.height / gridHeight;

    debugPrint('Slicing image'); // Changed from print to debugPrint

    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(recorder);
        final Rect srcRect = Rect.fromLTWH(
          x * sliceWidth,
          y * sliceHeight,
          sliceWidth,
          sliceHeight,
        );
        final Rect dstRect = Rect.fromLTWH(0, 0, sliceWidth, sliceHeight);
        canvas.drawImageRect(image, srcRect, dstRect, Paint());
        final ui.Image slice = await recorder.endRecording().toImage(
              sliceWidth.toInt(),
              sliceHeight.toInt(),
            );
        slices.add(slice);
      }
    }

    debugPrint('Sliced images count: ${slices.length}'); // Debug print

    return slices;
  }
}
