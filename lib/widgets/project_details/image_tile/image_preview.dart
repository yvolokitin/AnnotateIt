import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File file;
  final VoidCallback onTap;
  final bool hovered;

  const ImagePreview({required this.file, required this.onTap, required this.hovered, super.key});

  @override
  Widget build(BuildContext context) {
    final transform = hovered ? (Matrix4.identity()..scale(1.15)) : Matrix4.identity();
    
    // Get the last modified timestamp to use as a key
    final lastModified = file.lastModifiedSync().millisecondsSinceEpoch;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: transform,
      transformAlignment: Alignment.center,
      child: GestureDetector(
        onTap: onTap,
        child: Image.file(
          file,
          // Use a key based on the last modified timestamp to force refresh when the file changes
          key: ValueKey('image_${file.path}_$lastModified'),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          // Disable caching to ensure the image is always loaded from disk
          cacheWidth: null,
          cacheHeight: null,
        ),
      ),
    );
  }
}
