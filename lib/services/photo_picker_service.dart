import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// A simple service for picking images from the device Photos (iOS) or Gallery (Android).
/// Usage:
///   final images = await PhotoPickerService.pickMultipleImages();
///   final image = await PhotoPickerService.pickSingleImage();
class PhotoPickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick a single image from the library.
  static Future<XFile?> pickSingleImage({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 95,
  }) async {
    try {
      final result = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        // Log in debug builds; avoid crashing the app.
        print('pickSingleImage error: $e\n$st');
      }
      return null;
    }
  }

  /// Pick multiple images from the library (iOS 14+/Android supports multiple).
  static Future<List<XFile>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 95,
  }) async {
    try {
      // For most platforms, pickMultiImage is supported. It returns [] if cancelled.
      final results = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return results;
    } catch (e, st) {
      if (kDebugMode) {
        print('pickMultipleImages error: $e\n$st');
      }
      return <XFile>[];
    }
  }

  /// Helper to check if a picked file still exists on disk.
  static Future<bool> exists(XFile file) async {
    try {
      return await File(file.path).exists();
    } catch (_) {
      return false;
    }
  }
}
