import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/annotation.dart';
import '../models/label.dart';

/// A service that uses TFLite Flutter to detect objects in images and pre-fill bounding boxes
/// This service is only supported on Windows and macOS platforms
class TFLiteDetectionService {
  static final _logger = Logger('TFLiteDetectionService');
  static final TFLiteDetectionService _instance = TFLiteDetectionService._internal();
  
  factory TFLiteDetectionService() {
    return _instance;
  }
  
  TFLiteDetectionService._internal();
  
  /// The TFLite interpreter instance
  Interpreter? _interpreter;
  
  /// Flag to track if the service has been initialized
  bool _isInitialized = false;
  
  /// Flag to track if TFLite is supported on this platform
  bool _isSupported = false;

  /// Model input size
  int _inputSize = 300;
  
  /// Labels for the model
  List<String> _labels = [];
  
  /// Check if the current platform supports TFLite
  bool get isSupported => _isSupported;
  
  /// Initialize the TFLite service
  /// If already initialized, this will only update the configuration if needed
  Future<void> initialize({double confidenceThreshold = 0.5}) async {
    // If already initialized, just log and return
    if (_isInitialized) {
      _logger.info('TFLite service already initialized');
      return;
    }
    
    // TFLite Flutter should only be used on Windows/macOS platforms
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS)) {
      _logger.info('TFLite services are not supported on this platform');
      _isInitialized = true;
      _isSupported = false;
      return;
    }
    
    _isSupported = true;
    
    try {
      // Load the model
      // For this example, we'll use the SSD MobileNet model
      // In a real app, you would bundle the model with the app or download it
      final modelPath = await _getModelPath('ssd_mobilenet.tflite');
      final labelsPath = await _getModelPath('ssd_mobilenet_labels.txt');
      
      if (modelPath == null || labelsPath == null) {
        _logger.severe('Model or labels file not found');
        _isSupported = false;
        _isInitialized = true;
        return;
      }
      
      // Load labels
      final labelFile = File(labelsPath);
      if (await labelFile.exists()) {
        _labels = await labelFile.readAsLines();
        _logger.info('Loaded ${_labels.length} labels');
      } else {
        // Default labels for SSD MobileNet
        _labels = [
          'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', 'boat',
          'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench', 'bird', 'cat',
          'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', 'backpack',
          'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball',
          'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard', 'tennis racket',
          'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple',
          'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair',
          'couch', 'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse',
          'remote', 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink', 'refrigerator',
          'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier', 'toothbrush'
        ];
        _logger.info('Using default labels (${_labels.length})');
      }
      
      // Initialize interpreter
      final interpreterOptions = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromFile(File(modelPath), options: interpreterOptions);
      
      _isInitialized = true;
      _logger.info('TFLite service initialized with confidence threshold: $confidenceThreshold');
    } catch (e) {
      _logger.severe('Error initializing TFLite service', e);
      _isSupported = false;
      _isInitialized = true;
    }
  }
  
  /// Get the path to a model file
  /// First checks if the file exists in the app's documents directory
  /// If not, tries to load it from assets and copy it to a local directory
  Future<String?> _getModelPath(String fileName) async {
    try {
      // First, check if the model is in the app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final modelPath = path.join(appDir.path, fileName);
      
      // Check if the file exists in documents directory
      final file = File(modelPath);
      if (await file.exists()) {
        _logger.info('Found model file in documents directory: $fileName');
        return modelPath;
      }
      
      // If not in documents directory, try to load from assets
      final assetPath = 'assets/models/$fileName';
      
      try {
        // Create a directory for ML models if it doesn't exist
        final modelsDir = Directory(path.join(appDir.path, 'ml_models'));
        if (!await modelsDir.exists()) {
          await modelsDir.create(recursive: true);
        }
        
        // Path where we'll save the asset file
        final localPath = path.join(modelsDir.path, fileName);
        final localFile = File(localPath);
        
        // Check if we've already copied this asset before
        if (await localFile.exists()) {
          _logger.info('Using previously copied asset: $fileName');
          return localPath;
        }
        
        // Try to load the asset
        final ByteData data = await rootBundle.load(assetPath);
        final List<int> bytes = data.buffer.asUint8List();
        
        // Write the asset to a local file
        await localFile.writeAsBytes(bytes);
        _logger.info('Copied asset to local storage: $fileName');
        
        return localPath;
      } catch (assetError) {
        // Asset not found or couldn't be copied
        _logger.warning('Model file not found in assets: $fileName - $assetError');
      }
      
      // If we get here, the model wasn't found in documents or assets
      _logger.warning('Model file not found: $fileName');
      return null;
    } catch (e) {
      _logger.severe('Error getting model path', e);
      return null;
    }
  }
  
  /// Process an image file and return a list of detected objects with bounding boxes
  Future<List<DetectedObject>> processImageFile(File imageFile) async {
    // Check if initialized
    if (!_isInitialized) {
      _logger.warning('TFLite service not initialized. Initializing with default settings.');
      await initialize();
    }
    
    // Check if TFLite is supported on this platform
    if (!_isSupported || _interpreter == null) {
      _logger.warning('TFLite service is not supported or not initialized. Returning empty list.');
      return [];
    }
    
    try {
      // Load and preprocess the image
      final image = await _loadAndProcessImage(imageFile);
      
      // Run inference
      return _runInference(image);
    } catch (e) {
      _logger.severe('Error processing image file: ${imageFile.path}', e);
      return [];
    }
  }
  
  /// Process a ui.Image and return a list of detected objects with bounding boxes
  Future<List<DetectedObject>> processImage(ui.Image image) async {
    // Check if initialized
    if (!_isInitialized) {
      _logger.warning('TFLite service not initialized. Initializing with default settings.');
      await initialize();
    }
    
    // Check if TFLite is supported on this platform
    if (!_isSupported || _interpreter == null) {
      _logger.warning('TFLite service is not supported or not initialized. Returning empty list.');
      return [];
    }
    
    try {
      // Convert ui.Image to a format that TFLite can process
      final processedImage = await _preprocessUiImage(image);
      
      // Run inference
      return _runInference(processedImage);
    } catch (e) {
      _logger.severe('Error processing image', e);
      return [];
    }
  }
  
  /// Load and preprocess an image file for TFLite
  Future<List<List<List<double>>>> _loadAndProcessImage(File imageFile) async {
    // This is a simplified implementation
    // In a real app, you would use image processing libraries to resize and normalize the image
    
    // For now, we'll return a placeholder
    return List.generate(
      _inputSize,
      (y) => List.generate(
        _inputSize,
        (x) => List.generate(3, (c) => 0.0),
      ),
    );
  }
  
  /// Preprocess a ui.Image for TFLite
  Future<List<List<List<double>>>> _preprocessUiImage(ui.Image image) async {
    // This is a simplified implementation
    // In a real app, you would convert the ui.Image to a format that TFLite can process
    
    // For now, we'll return a placeholder
    return List.generate(
      _inputSize,
      (y) => List.generate(
        _inputSize,
        (x) => List.generate(3, (c) => 0.0),
      ),
    );
  }
  
  /// Run inference on the preprocessed image
  List<DetectedObject> _runInference(List<List<List<double>>> processedImage) {
    // This is a simplified implementation
    // In a real app, you would run the TFLite model on the processed image
    
    // For demonstration purposes, we'll return some placeholder detected objects
    return [
      DetectedObject(
        label: 'person',
        confidence: 0.95,
        boundingBox: Rect.fromLTWH(0.1, 0.1, 0.3, 0.6),
      ),
      DetectedObject(
        label: 'car',
        confidence: 0.85,
        boundingBox: Rect.fromLTWH(0.5, 0.2, 0.4, 0.3),
      ),
    ];
  }
  
  /// Convert detected objects to annotations
  List<Annotation> convertDetectionsToAnnotations({
    required List<DetectedObject> detections,
    required int mediaItemId,
    required List<Label> projectLabels,
    required int annotatorId,
  }) {
    final annotations = <Annotation>[];
    final now = DateTime.now();
    
    for (final detection in detections) {
      // Try to find a matching project label by name
      final matchingLabels = projectLabels.where(
        (label) => label.name.toLowerCase() == detection.label.toLowerCase()
      ).toList();
      
      // If no matching label is found, skip this detection
      if (matchingLabels.isEmpty) continue;
      
      final matchingLabel = matchingLabels.first;
      
      // Create annotation with bounding box data
      final annotationData = {
        'x': detection.boundingBox.left,
        'y': detection.boundingBox.top,
        'width': detection.boundingBox.width,
        'height': detection.boundingBox.height,
      };
      
      final annotation = Annotation(
        mediaItemId: mediaItemId,
        labelId: matchingLabel.id,
        annotationType: 'bbox',
        data: annotationData,
        confidence: detection.confidence,
        annotatorId: annotatorId,
        comment: 'Generated by TFLite Flutter',
        status: 'auto_generated',
        createdAt: now,
        updatedAt: now,
      )
      ..name = 'AI: ${detection.label}';
      
      annotations.add(annotation);
    }
    
    return annotations;
  }
  
  /// Get all detected objects, regardless of whether they match project labels
  List<DetectedObject> getDetectedObjects(List<DetectedObject> detections) {
    return detections;
  }
  
  /// Close the TFLite interpreter when it's no longer needed
  void close() {
    if (!_isInitialized) {
      _logger.info('TFLite service was not initialized, nothing to close');
      return;
    }
    
    try {
      if (_interpreter != null) {
        _interpreter!.close();
        _interpreter = null;
      }
    } catch (e) {
      _logger.warning('Error closing TFLite interpreter: ${e.toString()}');
    }
    
    // Reset initialization state
    _isInitialized = false;
    
    _logger.info('TFLite service closed');
  }
}

/// Class to represent a detected object with a bounding box
class DetectedObject {
  final String label;
  final double confidence;
  final Rect boundingBox;
  
  DetectedObject({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });
}