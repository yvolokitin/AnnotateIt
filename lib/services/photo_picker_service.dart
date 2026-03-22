import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// A simple service for picking images from the device Photos (iOS) or Gallery (Android).
/// Usage:
///   final images = await PhotoPickerService.pickMultipleImages();
///   final image = await PhotoPickerService.pickSingleImage();
class PhotoPickerService {
  static final ImagePicker _picker = ImagePicker();
  static const Duration _pickerTimeout = Duration(minutes: 2);
  static String? _lastError;

  /// Returns and clears the last picker error (if any).
  static String? takeLastError() {
    final err = _lastError;
    _lastError = null;
    return err;
  }

  /// Pick a single image from the library.
  static Future<XFile?> pickSingleImage({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 95,
  }) async {
    _lastError = null;
    try {
      final result = await _picker
          .pickImage(
            source: ImageSource.gallery,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: imageQuality,
            // Avoid triggering extra Photos permission prompts for metadata.
            requestFullMetadata: false,
          )
          .timeout(_pickerTimeout);
      return result;
    } on TimeoutException {
      _lastError =
          'Photos picker timed out. Check Photos access in Settings and try again.';
      return null;
    } catch (e, st) {
      _lastError = 'Unable to open Photos picker: $e';
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
    _lastError = null;
    try {
      // For most platforms, pickMultiImage is supported. It returns [] if cancelled.
      final results = await _picker
          .pickMultiImage(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: imageQuality,
            // Avoid triggering extra Photos permission prompts for metadata.
            requestFullMetadata: false,
          )
          .timeout(_pickerTimeout);
      return results;
    } on TimeoutException {
      _lastError =
          'Photos picker timed out. Check Photos access in Settings and try again.';
      return <XFile>[];
    } catch (e, st) {
      _lastError = 'Unable to open Photos picker: $e';
      if (kDebugMode) {
        print('pickMultipleImages error: $e\n$st');
      }
      return <XFile>[];
    }
  }

  /// Pick a single video from the Photos/Gallery.
  static Future<XFile?> pickSingleVideo({Duration? maxDuration}) async {
    _lastError = null;
    try {
      final result = await _picker
          .pickVideo(source: ImageSource.gallery, maxDuration: maxDuration)
          .timeout(_pickerTimeout);
      return result;
    } on TimeoutException {
      _lastError =
          'Photos picker timed out. Check Photos access in Settings and try again.';
      return null;
    } catch (e, st) {
      _lastError = 'Unable to open Photos picker: $e';
      if (kDebugMode) {
        print('pickSingleVideo error: $e\n$st');
      }
      return null;
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
