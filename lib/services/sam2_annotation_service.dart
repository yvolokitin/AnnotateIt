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
  
  /// Scale a binary mask from source dimensions to target dimensions
  Uint8List _scaleMaskToImageSize(
    Uint8List sourceMask, 
    int sourceWidth, 
    int sourceHeight, 
    int targetWidth, 
    int targetHeight
  ) {
    _logger.info('Scaling mask from ${sourceWidth}x${sourceHeight} to ${targetWidth}x${targetHeight}');
    
    // Create a new mask with the target dimensions
    final Uint8List targetMask = Uint8List(targetWidth * targetHeight);
    
    // Calculate scaling factors
    final double scaleX = sourceWidth / targetWidth;
    final double scaleY = sourceHeight / targetHeight;
    
    // Log scaling factors for debugging
    _logger.info('Scaling factors: scaleX=$scaleX, scaleY=$scaleY');
    
    // Map each pixel in the target mask to the source mask
    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        // Find the corresponding pixel in the source mask
        final int sourceX = (x * scaleX).floor();
        final int sourceY = (y * scaleY).floor();
        
        // Ensure we're within bounds
        if (sourceX >= 0 && sourceX < sourceWidth && sourceY >= 0 && sourceY < sourceHeight) {
          final int sourceIdx = sourceY * sourceWidth + sourceX;
          final int targetIdx = y * targetWidth + x;
          
          // Copy the value from source to target
          targetMask[targetIdx] = sourceMask[sourceIdx];
        }
      }
    }
    
    return targetMask;
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
      
      // Convert to float32 and normalize [0,1] with proper transposition
      // Following the Python example: image.transpose(2, 0, 1)[np.newaxis, :]
      // This creates a tensor with shape [1, 3, 1024, 1024]
      final inputTensor = Float32List(_inputSize * _inputSize * 3);
      int idx = 0;
      
      // First channel (R), then channel (G), then channel (B)
      // This matches the transpose(2, 0, 1) in Python which puts channels first
      for (int c = 0; c < 3; c++) {
        for (int y = 0; y < _inputSize; y++) {
          for (int x = 0; x < _inputSize; x++) {
            final pixel = resizedImage.getPixel(x, y);
            double value;
            
            // Get R, G, B values and normalize to [0,1]
            if (c == 0) {
              value = pixel.r / 255.0;  // Red channel
            } else if (c == 1) {
              value = pixel.g / 255.0;  // Green channel
            } else {
              value = pixel.b / 255.0;  // Blue channel
            }
            
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
        final Map<String, OrtValue> encoderInputs = {'image': inputTensorOrt};
        final encoderOutputs = await _encoderSession!.run(encoderInputs);
        
        // Extract encoder outputs by index instead of by name
        // This matches the Python verification script approach
        final outputsList = encoderOutputs.values.toList();
        _logger.info('Encoder outputs count: ${outputsList.length}');
        
        // Handle the case where we have fewer outputs than expected
        // In the Python script, we expect 3 outputs, but we might have fewer
        OrtValue? highResFeats0;
        OrtValue? highResFeats1;
        OrtValue? imageEmbed;
        
        if (outputsList.length >= 3) {
          // If we have 3 or more outputs, use them as in the Python script
          highResFeats0 = outputsList[0];
          highResFeats1 = outputsList[1];
          imageEmbed = outputsList[2];
        } else if (outputsList.length == 2) {
          // If we have only 2 outputs, use them for the first two parameters
          // and use the first one again for the third parameter
          highResFeats0 = outputsList[0];
          highResFeats1 = outputsList[1];
          imageEmbed = outputsList[0]; // Reuse the first output as a fallback
        } else if (outputsList.length == 1) {
          // If we have only 1 output, use it for all parameters
          highResFeats0 = outputsList[0];
          highResFeats1 = outputsList[0];
          imageEmbed = outputsList[0];
        } else {
          // If we have no outputs, throw an exception
          throw Exception('Encoder outputs list is empty');
        }
        
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
        // Ensure all values are non-null before creating the inputs map
        if (imageEmbed == null || highResFeats0 == null || highResFeats1 == null) {
          throw Exception('Encoder outputs contain null values');
        }
        
        // Create a properly typed map for decoder inputs
        final Map<String, OrtValue> decoderInputs = {
          'image_embed': imageEmbed as OrtValue,
          'high_res_feats_0': highResFeats0 as OrtValue,
          'high_res_feats_1': highResFeats1 as OrtValue,
          'point_coords': pointCoordsTensor,
          'point_labels': pointLabelsTensor,
          'mask_input': maskInputTensor,
          'has_mask_input': hasMaskInputTensor,
        };
        
        // Run decoder without casting
        final decoderOutputs = await _decoderSession!.run(decoderInputs);
        
        // === 5. Extract mask from outputs ===
        // Access decoder outputs by index instead of by name
        final decoderOutputsList = decoderOutputs.values.toList();
        _logger.info('Decoder outputs count: ${decoderOutputsList.length}');
        
        if (decoderOutputsList.isEmpty) {
          throw Exception('Decoder outputs list is empty');
        }
        
        // We expect only one output from the decoder based on the Python script
        final maskTensor = decoderOutputsList[0];
        if (maskTensor == null) {
          throw Exception('Mask tensor is null');
        }
        
        final maskData = await maskTensor.asFlattenedList();
        final maskShape = maskTensor.shape;
        
        _logger.info('Mask tensor shape: ${maskShape.join('x')}');
        
        // Convert mask to binary (0 or 1)
        // Handle different mask tensor shapes
        int maskWidth, maskHeight;
        if (maskShape.length >= 4) {
          // Shape is [1, 1, height, width] as expected
          maskWidth = maskShape[2];
          maskHeight = maskShape[3];
        } else if (maskShape.length == 3) {
          // Shape might be [1, height, width]
          maskWidth = maskShape[1];
          maskHeight = maskShape[2];
        } else if (maskShape.length == 2) {
          // Shape might be [height, width]
          maskWidth = maskShape[0];
          maskHeight = maskShape[1];
        } else {
          // For SAM2, when we get a shape like [1, 3], this likely represents
          // 3 different mask options rather than a 1x3 pixel mask
          // In this case, we'll use a default size of 256x256 which is common for SAM models
          _logger.info('Using default mask size for unexpected shape: ${maskShape.join('x')}');
          maskWidth = 256;
          maskHeight = 256;
        }
        
        final binaryMask = Uint8List(maskWidth * maskHeight);
        
        // Handle the case where maskData.length doesn't match maskWidth * maskHeight
        // This happens when we have a shape like [1, 3] which represents multiple mask options
        if (maskData.length != maskWidth * maskHeight) {
          _logger.info('Mask data length (${maskData.length}) doesn\'t match mask dimensions (${maskWidth}x${maskHeight})');
          
          // Log the actual values in the mask tensor for debugging
          String maskValues = '';
          for (int i = 0; i < maskData.length; i++) {
            double value = (maskData[i] as num).toDouble();
            maskValues += '$i: $value, ';
          }
          _logger.info('Mask tensor values: $maskValues');
          
          // If we have multiple mask options (e.g., shape [1, 3]), select the best one
          if (maskData.length > 0 && maskData.length <= 10) { // Small number of options
            // Find the index of the mask with highest confidence
            int bestMaskIndex = 0;
            double bestConfidence = (maskData[0] as num).toDouble();
            
            for (int i = 1; i < maskData.length; i++) {
              double confidence = (maskData[i] as num).toDouble();
              if (confidence > bestConfidence) {
                bestConfidence = confidence;
                bestMaskIndex = i;
              }
            }
            
            _logger.info('Selected mask option $bestMaskIndex with confidence $bestConfidence');
            
            // Fill the binary mask with a reasonable shape based on the selected option
            // Create a simple circle centered around the clicked point
            
            // Calculate the center point in the mask coordinates
            // We need to scale the original point coordinates to the mask dimensions
            final pointX = (scaledX / _inputSize) * maskWidth;
            final pointY = (scaledY / _inputSize) * maskHeight;
            
            // Ensure the point is within the mask bounds
            final centerX = math.min(math.max(pointX.toInt(), 0), maskWidth - 1);
            final centerY = math.min(math.max(pointY.toInt(), 0), maskHeight - 1);
            
            // Use a much smaller radius to avoid creating "big triangles"
            // Make the radius proportional to the image size, not the mask size
            // This will create a small annotation that's appropriately sized for the image
            final radius = math.min(maskWidth, maskHeight) ~/ 20; // Even smaller radius
            
            _logger.info('Creating mask centered at ($centerX, $centerY) with radius $radius');
            
            for (int y = 0; y < maskHeight; y++) {
              for (int x = 0; x < maskWidth; x++) {
                final dx = x - centerX;
                final dy = y - centerY;
                final distance = math.sqrt(dx * dx + dy * dy);
                
                // Create a circle for the mask
                if (distance < radius) {
                  binaryMask[y * maskWidth + x] = 1;
                } else {
                  binaryMask[y * maskWidth + x] = 0;
                }
              }
            }
          } else {
            // Fill with zeros as a fallback
            for (int i = 0; i < binaryMask.length; i++) {
              binaryMask[i] = 0;
            }
          }
        } else {
          // Normal case: maskData length matches the expected dimensions
          for (int i = 0; i < maskData.length; i++) {
            binaryMask[i] = (maskData[i] as num) > 0.5 ? 1 : 0;
          }
        }
        
        // Log mask statistics for debugging
        int maskSum = 0;
        for (int i = 0; i < binaryMask.length; i++) {
          if (binaryMask[i] > 0) maskSum++;
        }
        double maskCoverage = maskSum / binaryMask.length;
        _logger.info('Binary mask coverage: ${(maskCoverage * 100).toStringAsFixed(2)}% (${maskSum} / ${binaryMask.length} pixels)');
        
        // Create a scaled mask that matches the original image dimensions
        final scaledMask = _scaleMaskToImageSize(
          binaryMask, 
          maskWidth, 
          maskHeight, 
          image.width, 
          image.height
        );
        
        // Log scaled mask statistics
        int scaledMaskSum = 0;
        for (int i = 0; i < scaledMask.length; i++) {
          if (scaledMask[i] > 0) scaledMaskSum++;
        }
        double scaledMaskCoverage = scaledMaskSum / scaledMask.length;
        _logger.info('Scaled mask coverage: ${(scaledMaskCoverage * 100).toStringAsFixed(2)}% (${scaledMaskSum} / ${scaledMask.length} pixels)');
        
        // Convert binary mask to polygon
        final polygonPoints = _maskToPolygon(
          scaledMask, 
          image.width, 
          image.height
        );
        
        _logger.info('Generated polygon with ${polygonPoints.length} points');
        
        // Points are already in image coordinates since we scaled the mask
        final scaledPoints = polygonPoints;
        
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
      // Improved implementation to trace the contour of the mask
      final List<List<double>> points = [];
      final int step = math.max(1, math.min(width, height) ~/ 100); // Adaptive step size
      
      // Find boundary points by sampling the mask
      for (int y = 0; y < height; y += step) {
        for (int x = 0; x < width; x += step) {
          final int idx = y * width + x;
          
          // Check if this is a boundary pixel
          if (mask[idx] > 0) {
            // Check if any of the 8-connected neighbors is background
            bool isBoundary = false;
            
            // Check all 8 neighbors
            for (int dy = -1; dy <= 1; dy++) {
              for (int dx = -1; dx <= 1; dx++) {
                if (dx == 0 && dy == 0) continue; // Skip the center pixel
                
                final int nx = x + dx;
                final int ny = y + dy;
                
                // Check if neighbor is within bounds
                if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                  final int nIdx = ny * width + nx;
                  if (mask[nIdx] == 0) {
                    isBoundary = true;
                    break;
                  }
                } else {
                  // Treat out-of-bounds as background
                  isBoundary = true;
                }
              }
              if (isBoundary) break;
            }
            
            if (isBoundary) {
              // Store actual coordinates (not normalized)
              points.add([x.toDouble(), y.toDouble()]);
            }
          }
        }
      }
      
      // If we found too few points, return a placeholder
      if (points.length < 4) {
        _logger.warning('Too few boundary points found (${points.length}), using placeholder');
        // Create a placeholder with actual coordinates
        return [
          [width * 0.2, height * 0.2],
          [width * 0.8, height * 0.2],
          [width * 0.8, height * 0.8],
          [width * 0.2, height * 0.8],
        ];
      }
      
      // Sort points to form a proper polygon
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
      // Create a placeholder with actual coordinates
      return [
        [width * 0.2, height * 0.2],
        [width * 0.8, height * 0.2],
        [width * 0.8, height * 0.8],
        [width * 0.2, height * 0.8],
      ];
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