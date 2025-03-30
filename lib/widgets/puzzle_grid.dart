import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class PuzzleGrid extends StatelessWidget {
  final List<int> tiles;
  final int gridWidth;
  final int gridHeight;
  final List<ui.Image> slicedImages;
  final Function(int) onTap;

  const PuzzleGrid({
    required this.tiles,
    required this.gridWidth,
    required this.gridHeight,
    required this.slicedImages,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double tileWidth = constraints.maxWidth / gridWidth;
        double tileHeight = constraints.maxHeight / gridHeight;

        return GridView.builder(
          padding: const EdgeInsets.all(0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridWidth,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            if (tiles[index] == 0) {
              return Container(
                width: tileWidth,
                height: tileHeight,
                color: Colors.transparent,
              );
            } else {
              return GestureDetector(
                onTap: () => onTap(index),
                child: Stack(
                  children: [
                    Container(
                      width: tileWidth,
                      height: tileHeight,
                      decoration: const BoxDecoration(),
                      child: slicedImages.isNotEmpty
                          ? RawImage(
                              image: slicedImages[tiles[index] - 1],
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey),
                    ),
                    Center(
                      child: Text(
                        '${tiles[index]}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}
