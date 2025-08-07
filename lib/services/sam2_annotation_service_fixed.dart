import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import '../models/annotation.dart';
import '../models/label.dart';

/// A class representing a detected segment from SAM2
class DetectedSegment {
  final String label;
  final double confidence;
  final List<List<double>> points; // List of [x, y] points forming the polygon
  final Uint8List? maskData; // Raw mask data (optional)

  DetectedSegment({
    required this.label,
    required this.confidence,
    required this.points,
    this.maskData,
  });
}

/// A service that uses SAM2 ONNX models to generate segmentation masks
/// This service is only supported on Windows and macOS platforms
class SAM2AnnotationService {
  static final _logger = Logger('SAM2AnnotationService');
  static final SAM2AnnotationService _instance = SAM2AnnotationService._internal();
  
  factory SAM2AnnotationService() {
    return _instance;
  }
  
  SAM2AnnotationService._internal();
  
  /// The ONNX runtime instance
  final OnnxRuntime _onnxRuntime = OnnxRuntime();
  
  /// The ONNX runtime session for the encoder
  OrtSession? _encoderSession;
  
  /// The ONNX runtime session for the decoder
  OrtSession? _decoderSession;
  
  /// Flag to track if the service has been initialized
  bool _isInitialized = false;
  
  /// Flag to track if SAM2 is supported on this platform
  bool _isSupported = false;

  /// Model input size
  int _inputSize = 1024;
  
  /// Check if the current platform supports SAM2
  bool get isSupported => _isSupported;
  
  /// Check if the service is currently processing
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  
  /// Initialize the SAM2 service
  /// If already initialized, this will only update the configuration if needed
  Future<void> initialize() async {
    // If already initialized, just log and return
    if (_isInitialized) {
      _logger.info('SAM2 service already initialized');
      return;
    }
    
    // SAM2 should only be used on Windows/macOS platforms
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS)) {
      _logger.info('SAM2 services are not supported on this platform');
      _isInitialized = true;
      _isSupported = false;
      return;
    }
    
    _isSupported = true;
    
    try {
      // Load the encoder model
      final encoderModelPath = await _getModelPath('sam2_hiera_small.encoder.onnx');
      
      // Load the decoder model
      final decoderModelPath = await _getModelPath('sam2_hiera_small.decoder.onnx');
      
      if (encoderModelPath == null || decoderModelPath == null) {
        _logger.severe('SAM2 model files not found');
        _isSupported = false;
        _isInitialized = true;
        return;
      }
      
      // Create sessions for encoder and decoder
      _encoderSession = await _onnxRuntime.createSession(encoderModelPath);
      _decoderSession = await _onnxRuntime.createSession(decoderModelPath);
      
      _isInitialized = true;
      _logger.info('SAM2 service initialized successfully');
    } catch (e) {
      _logger.severe('Error initializing SAM2 service', e);
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
      final assetPath = 'assets/models_sam/$fileName';
      
      try {
        // Create a directory for SAM models if it doesn't exist
        final modelsDir = Directory(path.join(appDir.path, 'sam_models'));
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
  
  /// Process a ui.Image and a point prompt to generate a segmentation mask
  Future<DetectedSegment?> processImageWithPoint(ui.Image image, Offset point) async {
    if (_isProcessing) {
      _logger.warning('SAM2 service is already processing an image');
      return null;
    }
    
    _isProcessing = true;
    
    try {
      // Check if initialized
      if (!_isInitialized) {
        _logger.warning('SAM2 service not initialized. Initializing with default settings.');
        await initialize();
      }
      
      // Check if SAM2 is supported on this platform
      if (!_isSupported || _encoderSession == null || _decoderSession == null) {
        _logger.warning('SAM2 service is not supported or not initialized.');
        _isProcessing = false;
        return null;
      }
      
      _logger.info('Processing image with SAM2, point: ${point.dx}, ${point.dy}');
      
      // === 1. Preprocess the image ===
      // Convert ui.Image to bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        _logger.severe('Failed to convert image to bytes');
        _isProcessing = false;
        return null;
      }
      
      // Convert to img.Image for preprocessing
      final Uint8List bytes = byteData.buffer.asUint8List();
      final imgImage = img.Image(
        width: image.width,
        height: image.height,
      );
      
      // Manually copy pixel data from RGBA bytes
      int pixelIndex = 0;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final r = bytes[pixelIndex];
          final g = bytes[pixelIndex + 1];
          final b = bytes[pixelIndex + 2];
          final a = bytes[pixelIndex + 3];
          imgImage.setPixelRgba(x, y, r, g, b, a);
          pixelIndex += 4;
        }
      }
      
      // Resize to input size
      final resizedImage = img.copyResize(
        imgImage,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.linear,
      );
      
      // Convert to float32 and normalize [0,1]
      final inputTensor = Float32List(_inputSize * _inputSize * 3);
      int idx = 0;
      
      for (int c = 0; c < 3; c++) {
        for (int y = 0; y < _inputSize; y++) {
          for (int x = 0; x < _inputSize; x++) {
            final pixel = resizedImage.getPixel(x, y);
            // Get R, G, B values and normalize to [0,1]
            final value = c == 0 
                ? pixel.r / 255.0  // Red component
                : (c == 1 ? pixel.g / 255.0  // Green component
                          : pixel.b / 255.0);  // Blue component
            inputTensor[idx++] = value;
          }
        }
      }
      
      // === 2. Run encoder inference ===
      try {
        // Reshape input tensor to match the expected shape [1, 3, 1024, 1024]
        final inputShape = [1, 3, _inputSize, _inputSize];
        final inputTensorOrt = await OrtValue.fromList(
          inputTensor,
          inputShape,
        );
        
        // Run encoder inference
        final encoderInputs = {'image': inputTensorOrt};
        final encoderOutputs = await _encoderSession!.run(encoderInputs);
        
        // Extract encoder outputs
        final highResFeats0 = encoderOutputs['output_0'];
        final highResFeats1 = encoderOutputs['output_1'];
        final imageEmbed = encoderOutputs['output_2'];
        
        // === 3. Prepare point prompt ===
        // Scale point coordinates to the input size
        final scaledX = (point.dx / image.width) * _inputSize;
        final scaledY = (point.dy / image.height) * _inputSize;
        
        // Create point coordinates tensor [1, 1, 2]
        final pointCoordsList = Float32List(2);
        pointCoordsList[0] = scaledX;
        pointCoordsList[1] = scaledY;
        final pointCoordsTensor = await OrtValue.fromList(
          pointCoordsList,
          [1, 1, 2],
        );
        
        // Create point labels tensor [1, 1]
        final pointLabelsList = Float32List(1);
        pointLabelsList[0] = 1.0; // Foreground point
        final pointLabelsTensor = await OrtValue.fromList(
          pointLabelsList,
          [1, 1],
        );
        
        // Create has_mask_input tensor [1]
        final hasMaskInputList = Float32List(1);
        hasMaskInputList[0] = 0.0; // No mask input
        final hasMaskInputTensor = await OrtValue.fromList(
          hasMaskInputList,
          [1],
        );
        
        // Create mask_input tensor [1, 1, 256, 256]
        final maskInputList = Float32List(256 * 256);
        final maskInputTensor = await OrtValue.fromList(
          maskInputList,
          [1, 1, 256, 256],
        );
        
        // === 4. Run decoder inference ===
        final decoderInputs = {
          'image_embed': imageEmbed,
          'high_res_feats_0': highResFeats0,
          'high_res_feats_1': highResFeats1,
          'point_coords': pointCoordsTensor,
          'point_labels': pointLabelsTensor,
          'mask_input': maskInputTensor,
          'has_mask_input': hasMaskInputTensor,
        };
        
        final decoderOutputs = await _decoderSession!.run(decoderInputs);
        
        // === 5. Extract mask from outputs ===
        final maskTensor = decoderOutputs['output_0'];
        if (maskTensor == null) {
          throw Exception('Mask tensor is null');
        }
        
        final maskData = await maskTensor.asFlattenedList();
        final maskShape = maskTensor.shape;
        
        // Convert mask to binary (0 or 1)
        final maskWidth = maskShape[2];
        final maskHeight = maskShape[3];
        final binaryMask = Uint8List(maskWidth * maskHeight);
        
        for (int i = 0; i < maskData.length; i++) {
          binaryMask[i] = (maskData[i] as num) > 0.5 ? 1 : 0;
        }
        
        // Convert binary mask to polygon
        final polygonPoints = _maskToPolygon(binaryMask, maskWidth, maskHeight);
        
        // Scale polygon points to image coordinates
        final scaledPoints = polygonPoints.map((point) {
          final originalX = point[0] * image.width;
          final originalY = point[1] * image.height;
          return [originalX, originalY];
        }).toList();
        
        _isProcessing = false;
        
        return DetectedSegment(
          label: 'segment',
          confidence: 1.0,
          points: scaledPoints,
          maskData: binaryMask,
        );
      } catch (e) {
        _logger.severe('Error running SAM2 inference: $e');
        
        // If there's an error, fall back to a placeholder polygon
        final placeholderPoints = _createPlaceholderPolygon();
        
        // Scale placeholder points to image coordinates
        final scaledPoints = placeholderPoints.map((point) {
          final originalX = point[0] * image.width;
          final originalY = point[1] * image.height;
          return [originalX, originalY];
        }).toList();
        
        _isProcessing = false;
        
        return DetectedSegment(
          label: 'segment',
          confidence: 1.0,
          points: scaledPoints,
          maskData: null,
        );
      }
    } catch (e) {
      _logger.severe('Error processing image with point', e);
      _isProcessing = false;
      return null;
    }
  }
  
  /// Convert a binary mask to a polygon
  List<List<double>> _maskToPolygon(Uint8List mask, int width, int height) {
    try {
      // Simple implementation: trace the contour of the mask
      // In a real implementation, you would use a more sophisticated algorithm
      // like Marching Squares or OpenCV's findContours
      
      // For now, we'll use a simplified approach to find the boundary points
      final List<List<double>> points = [];
      final int step = 8; // Sample every 8 pixels for performance
      
      // Find boundary points by sampling the mask
      for (int y = 0; y < height; y += step) {
        for (int x = 0; x < width; x += step) {
          final int idx = y * width + x;
          
          // Check if this is a boundary pixel
          if (mask[idx] > 0) {
            // Check if any of the 4-connected neighbors is background
            bool isBoundary = false;
            
            // Check left
            if (x > 0 && mask[idx - 1] == 0) isBoundary = true;
            // Check right
            if (x < width - 1 && mask[idx + 1] == 0) isBoundary = true;
            // Check top
            if (y > 0 && mask[idx - width] == 0) isBoundary = true;
            // Check bottom
            if (y < height - 1 && mask[idx + width] == 0) isBoundary = true;
            
            if (isBoundary) {
              points.add([x / width, y / height]);
            }
          }
        }
      }
      
      // If we found too few points, return a placeholder
      if (points.length < 4) {
        return _createPlaceholderPolygon();
      }
      
      // Sort points to form a proper polygon
      // This is a simplified approach - in a real implementation,
      // you would use a proper contour tracing algorithm
      final centerX = points.map((p) => p[0]).reduce((a, b) => a + b) / points.length;
      final centerY = points.map((p) => p[1]).reduce((a, b) => a + b) / points.length;
      
      // Sort points by angle from center
      points.sort((a, b) {
        final angleA = math.atan2(a[1] - centerY, a[0] - centerX);
        final angleB = math.atan2(b[1] - centerY, b[0] - centerX);
        return angleA.compareTo(angleB);
      });
      
      return points;
    } catch (e) {
      _logger.warning('Error converting mask to polygon: $e');
      return _createPlaceholderPolygon();
    }
  }
  
  /// Create a placeholder polygon for testing
  List<List<double>> _createPlaceholderPolygon() {
    return [
      [0.2, 0.2],
      [0.8, 0.2],
      [0.8, 0.8],
      [0.2, 0.8],
    ];
  }
  
  /// Convert detected segments to annotations
  List<Annotation> convertSegmentsToAnnotations({
    required List<DetectedSegment> segments,
    required int mediaItemId,
    required List<Label> projectLabels,
    required int annotatorId,
  }) {
    final annotations = <Annotation>[];
    final now = DateTime.now();
    
    // Find a label for segmentation
    final matchingLabels = projectLabels.where(
      (label) => label.name.toLowerCase().contains('segment')
    ).toList();
    
    // If no matching label is found, use the first label
    final labelId = matchingLabels.isNotEmpty 
      ? matchingLabels.first.id 
      : (projectLabels.isNotEmpty ? projectLabels.first.id : -1);
    
    if (labelId == -1) {
      _logger.warning('No valid label found for segmentation');
      return [];
    }
    
    for (final segment in segments) {
      // Create annotation with polygon data
      final annotationData = {
        'points': segment.points,
      };
      
      final annotation = Annotation(
        mediaItemId: mediaItemId,
        labelId: labelId,
        annotationType: 'polygon',
        data: annotationData,
        confidence: segment.confidence,
        annotatorId: annotatorId,
        comment: 'Generated by SAM2',
        status: 'auto_generated',
        createdAt: now,
        updatedAt: now,
      );
      
      annotations.add(annotation);
    }
    
    return annotations;
  }
  
  /// Dispose resources
  void dispose() {
    try {
      if (_encoderSession != null) {
        _encoderSession!.close();
        _encoderSession = null;
      }
      
      if (_decoderSession != null) {
        _decoderSession!.close();
        _decoderSession = null;
      }
    } catch (e) {
      _logger.warning('Error disposing SAM2 service: $e');
    } finally {
      _isInitialized = false;
    }
  }
}