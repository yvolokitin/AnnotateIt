import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_ml_kit/google_ml_kit.dart' as ml_kit;
import 'package:logging/logging.dart';

import '../models/annotation.dart';
import '../models/label.dart';

/// A service that uses Google ML Kit to label images
class MLKitImageLabelingService {
  static final _logger = Logger('MLKitImageLabelingService');
  static final MLKitImageLabelingService _instance = MLKitImageLabelingService._internal();
  
  factory MLKitImageLabelingService() {
    return _instance;
  }
  
  MLKitImageLabelingService._internal();
  
  /// The image labeler instance from ML Kit
  ml_kit.ImageLabeler? _imageLabeler;
  
  /// The object detector instance from ML Kit
  ml_kit.ObjectDetector? _objectDetector;
  
  /// Flag to track if the service has been initialized
  bool _isInitialized = false;
  
  /// Flag to track if ML Kit is supported on this platform
  bool _isSupported = false;
  
  /// Check if the current platform supports ML Kit
  bool get isSupported => _isSupported;
  
  /// Initialize the ML Kit services with the given confidence threshold
  /// If already initialized, this will only update the configuration if the threshold changes
  void initialize({double confidenceThreshold = 0.5}) {
    // If already initialized, just log and return
    if (_isInitialized) {
      _logger.info('ML Kit services already initialized');
      return;
    }
    
    // Check if the current platform is supported
    // ML Kit is only supported on Android and iOS
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      _logger.info('ML Kit services are not supported on this platform');
      _isInitialized = true;
      _isSupported = false;
      return;
    }
    
    _isSupported = true;
    
    try {
      // Initialize image labeler for classification
      final options = ml_kit.ImageLabelerOptions(confidenceThreshold: confidenceThreshold);
      _imageLabeler = ml_kit.ImageLabeler(options: options);
      
      // Initialize object detector for detection
      final detectorOptions = ml_kit.ObjectDetectorOptions(
        mode: ml_kit.DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ml_kit.ObjectDetector(options: detectorOptions);
      
      _isInitialized = true;
      _logger.info('ML Kit services initialized with confidence threshold: $confidenceThreshold');
    } catch (e) {
      _logger.severe('Error initializing ML Kit services', e);
      _isSupported = false;
      _isInitialized = true;
    }
  }
  
  /// Process an image file and return a list of labels with confidence scores
  /// The processing method depends on the project type
  Future<List<ml_kit.ImageLabel>> processImageFile(File imageFile, {String projectType = ''}) async {
    // Check if initialized
    if (!_isInitialized) {
      _logger.warning('ML Kit services not initialized. Initializing with default settings.');
      initialize();
    }
    
    // Check if ML Kit is supported on this platform
    if (!_isSupported) {
      _logger.warning('ML Kit services are not supported on this platform. Returning empty list.');
      return [];
    }
    
    try {
      final inputImage = ml_kit.InputImage.fromFile(imageFile);
      
      if (projectType.toLowerCase().contains('detection')) {
        // For detection project types, use object detection
        final objects = await _objectDetector?.processImage(inputImage) ?? [];
        _logger.info('Processed image file with object detection: ${imageFile.path}, found ${objects.length} objects');
        
        // Convert detected objects to ImageLabel format for compatibility
        return objects.map((object) {
          return ml_kit.ImageLabel(
            label: object.labels.isNotEmpty ? object.labels.first.text : 'Object',
            confidence: object.labels.isNotEmpty ? object.labels.first.confidence : 0.5,
            index: 0,
          );
        }).toList();
      } else {
        // For classification and other project types, use image labeling
        if (_imageLabeler == null) {
          _logger.warning('Image labeler is null. Returning empty list.');
          return [];
        }
        
        final labels = await _imageLabeler!.processImage(inputImage);
        _logger.info('Processed image file with classification: ${imageFile.path}, found ${labels.length} labels');
        return labels;
      }
    } catch (e) {
      _logger.severe('Error processing image file: ${imageFile.path}', e);
      return [];
    }
  }

  /// Process an image and return a list of labels with confidence scores
  /// The processing method depends on the project type
  Future<List<ml_kit.ImageLabel>> processImage(ui.Image image, {String projectType = ''}) async {
    // Check if initialized
    if (!_isInitialized) {
      _logger.warning('ML Kit services not initialized. Initializing with default settings.');
      initialize();
    }
    
    // Check if ML Kit is supported on this platform
    if (!_isSupported) {
      _logger.warning('ML Kit services are not supported on this platform. Returning empty list.');
      return [];
    }
    
    try {
      // Convert ui.Image to InputImage
      final inputImage = await _convertUiImageToInputImage(image);
      
      if (projectType.toLowerCase().contains('detection')) {
        // For detection project types, use object detection
        final objects = await _objectDetector?.processImage(inputImage) ?? [];
        _logger.info('Processed image with object detection, found ${objects.length} objects');
        
        // Convert detected objects to ImageLabel format for compatibility
        return objects.map((object) {
          return ml_kit.ImageLabel(
            label: object.labels.isNotEmpty ? object.labels.first.text : 'Object',
            confidence: object.labels.isNotEmpty ? object.labels.first.confidence : 0.5,
            index: 0,
          );
        }).toList();
      } else {
        // For classification and other project types, use image labeling
        if (_imageLabeler == null) {
          _logger.warning('Image labeler is null. Returning empty list.');
          return [];
        }
        
        final labels = await _imageLabeler!.processImage(inputImage);
        _logger.info('Processed image with classification, found ${labels.length} labels');
        return labels;
      }
    } catch (e) {
      _logger.severe('Error processing image', e);
      return [];
    }
  }
  
  /// Convert a ui.Image to an InputImage
  /// This is a simplified approach - in a real app, you might need to convert the ui.Image to a file or bytes
  Future<ml_kit.InputImage> _convertUiImageToInputImage(ui.Image image) async {
    // This is a placeholder implementation
    // In a real app, you would need to convert the ui.Image to a format that ML Kit can process
    // For example, you might need to convert it to a File or Uint8List
    
    // For demonstration purposes, we'll create a temporary file from the image
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    final tempDir = await Directory.systemTemp.createTemp('ml_kit_temp');
    final tempFile = File('${tempDir.path}/temp_image.png');
    await tempFile.writeAsBytes(buffer);
    
    return ml_kit.InputImage.fromFile(tempFile);
  }
  
  /// Convert ML Kit image labels to annotations
  /// The annotation type depends on the project type
  List<Annotation> convertLabelsToAnnotations({
    required List<ml_kit.ImageLabel> labels,
    required int mediaItemId,
    required List<Label> projectLabels,
    required int annotatorId,
    String projectType = '',
  }) {
    final annotations = <Annotation>[];
    final now = DateTime.now();
    final type = projectType.toLowerCase();
    
    // Determine the annotation type based on project type
    String annotationType = 'classification';
    if (type.contains('detection')) {
      annotationType = 'bbox';
    } else if (type.contains('segmentation')) {
      annotationType = 'polygon';
    }
    
    for (final imageLabel in labels) {
      // Try to find a matching project label by name
      final matchingLabels = projectLabels.where(
        (label) => label.name.toLowerCase() == imageLabel.label.toLowerCase()
      ).toList();
      
      // If no matching label is found, skip this image label
      if (matchingLabels.isEmpty) continue;
      
      final matchingLabel = matchingLabels.first;
      
      // Create annotation with appropriate type and data
      Map<String, dynamic> annotationData = {'label': imageLabel.label};
      
      // For detection types, add bounding box data
      if (annotationType == 'bbox') {
        // Create a default bounding box in the center of the image
        // In a real implementation, this would come from the object detector
        annotationData = {
          'x': 0.25,
          'y': 0.25,
          'width': 0.5,
          'height': 0.5,
        };
      } else if (annotationType == 'polygon') {
        // Create a default polygon for segmentation
        // In a real implementation, this would come from a segmentation model
        annotationData = {
          'points': [
            {'x': 0.25, 'y': 0.25},
            {'x': 0.75, 'y': 0.25},
            {'x': 0.75, 'y': 0.75},
            {'x': 0.25, 'y': 0.75},
          ]
        };
      }
      
      final annotation = Annotation(
        mediaItemId: mediaItemId,
        labelId: matchingLabel.id,
        annotationType: annotationType,
        data: annotationData,
        confidence: imageLabel.confidence,
        annotatorId: annotatorId,
        comment: 'Generated by Google ML Kit',
        status: 'auto_generated',
        createdAt: now,
        updatedAt: now,
      )
      ..name = 'AI: ${imageLabel.label}';
      
      annotations.add(annotation);
    }
    
    return annotations;
  }
  
  /// Get all detected labels from ML Kit, regardless of whether they match project labels
  List<ml_kit.ImageLabel> getDetectedLabels(List<ml_kit.ImageLabel> labels) {
    return labels;
  }
  
  /// Close all ML Kit services when they're no longer needed
  void close() {
    if (!_isInitialized) {
      _logger.info('ML Kit services were not initialized, nothing to close');
      return;
    }
    
    // If ML Kit is not supported on this platform, just reset state without trying to close services
    if (!_isSupported) {
      _logger.info('ML Kit services are not supported on this platform, resetting state only');
      _isInitialized = false;
      _imageLabeler = null;
      _objectDetector = null;
      return;
    }
    
    try {
      if (_imageLabeler != null) {
        try {
          _imageLabeler!.close();
        } catch (e) {
          if (e.toString().contains('MissingPluginException')) {
            _logger.info('Ignoring MissingPluginException when closing image labeler');
          } else {
            _logger.warning('Error closing image labeler: ${e.toString()}');
          }
        }
      }
    } catch (e) {
      _logger.warning('Error accessing image labeler: ${e.toString()}');
    }
    
    try {
      if (_objectDetector != null) {
        try {
          _objectDetector!.close();
        } catch (e) {
          if (e.toString().contains('MissingPluginException')) {
            _logger.info('Ignoring MissingPluginException when closing object detector');
          } else {
            _logger.warning('Error closing object detector: ${e.toString()}');
          }
        }
      }
    } catch (e) {
      _logger.warning('Error accessing object detector: ${e.toString()}');
    }
    
    // Reset initialization state
    _isInitialized = false;
    _imageLabeler = null;
    _objectDetector = null;
    
    _logger.info('ML Kit services closed');
  }
}