import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:logging/logging.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../session/user_session.dart';

class ClassificationResult {
  final String label;
  final double score;
  ClassificationResult(this.label, this.score);
}

class TFLiteClassificationService {
  static const String defaultClassificationModelId = 'classification_efficientnet-tflite-lite0-int8-v2';

  Future<String> _modelsRoot() async {
    try {
      return await UserSession.instance.getCurrentUserModelsFolder();
    } catch (_) {
      // Fallback: use Documents/AnnotateIt/models
      final dir = await getApplicationDocumentsDirectory();
      return dir.path + '/AnnotateIt/models';
    }
  }

  Future<bool> isModelAvailableInUserFolder({
    String modelId = defaultClassificationModelId,
    String? modelFileName,
    String? labelsFileName,
  }) async {
    final root = await _modelsRoot();
    final folder = Directory('$root/$modelId');

    print('folder path: ${folder.path}');

    if (!await folder.exists()) return false;

    final model = File('$root/$modelId/${modelFileName ?? '$modelId.tflite'}');
    final labels = File('$root/$modelId/${labelsFileName ?? '${modelId}_labels.txt'}');

    print('model path: ${model.path}, labels path: ${labels.path}');

    final modelOk = await model.exists() && (await model.length()) > 1024; // >1KB
    final labelsOk = await labels.exists() && (await labels.length()) > 0;

    return modelOk && labelsOk;
  }

  Future<void> initializeFromUserFolder({
    String modelId = defaultClassificationModelId,
    String? modelFileName,
    String? labelsFileName,
  }) async {
    final root = await _modelsRoot();
    final modelPath = '$root/$modelId/${modelFileName ?? '$modelId.tflite'}';
    final labelsPath = '$root/$modelId/${labelsFileName ?? '${modelId}_labels.txt'}';

    final model = File(modelPath);
    final labels = File(labelsPath);

    if (!await model.exists() || !await labels.exists()) {
      throw Exception('TFLite model not found in user models folder. Please download it from the Model screen.');
    }
    await initializeFromFiles(modelFilePath: modelPath, labelsFilePath: labelsPath);
  }
  final _log = Logger('TFLiteClassificationService');

  Interpreter? _interpreter;
  List<String> _labels = const [];

  bool get isInitialized => _interpreter != null && _labels.isNotEmpty;

  Future<void> dispose() async {
    try {
      _interpreter?.close();
    } catch (_) {}
    _interpreter = null;
  }

  Future<void> initialize({
    String modelAssetPath = 'assets/models/classification.tflite',
    String labelsAssetPath = 'assets/models/ssd_mobilenet_labels.txt',
  }) async {
    await dispose();
    try {
      // Try to load labels from assets
      final labelsStr = await rootBundle.loadString(labelsAssetPath);
      _labels = labelsStr.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } catch (e) {
      _log.warning('Failed to load labels from assets: $e');
      _labels = const [];
    }

    try {
      // Load interpreter from assets. Requires pubspec to include assets/models.
      _interpreter = await Interpreter.fromAsset(modelAssetPath);
      _log.info('TFLite model loaded from assets: $modelAssetPath');
    } catch (e) {
      _log.warning('Failed to load model from assets ($modelAssetPath): $e');
      rethrow; // Let caller handle showing message
    }
  }

  Future<void> initializeFromFiles({
    required String modelFilePath,
    required String labelsFilePath,
  }) async {
    await dispose();
    try {
      final labelsStr = await File(labelsFilePath).readAsString();
      _labels = labelsStr.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } catch (e) {
      _log.warning('Failed to load labels from file: $e');
      _labels = const [];
    }

    try {
      _interpreter = Interpreter.fromFile(File(modelFilePath));
      _log.info('TFLite model loaded from file: $modelFilePath');
    } catch (e) {
      _log.warning('Failed to load model from file ($modelFilePath): $e');
      final msg = e.toString();
      if (Platform.isWindows && (msg.contains('libtensorflowlite_c-win') || msg.contains('Failed to load dynamic library'))) {
        throw Exception('TensorFlow Lite runtime is missing on Windows. Please reinstall the app or ensure libtensorflowlite_c-win.dll is present next to the executable or in the "blobs" subfolder. See TFLITE_MODEL_SETUP.md for details.');
      }
      rethrow;
    }
  }

  Future<ClassificationResult?> classifyImage(File file, {int topK = 1}) async {
    if (_interpreter == null) return null;

    // Decode image
    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return null;

    // Get input tensor shape, e.g., [1, 224, 224, 3] or [1, 3, 224, 224]
    final inputTensor = _interpreter!.getInputTensor(0);
    final inputShape = inputTensor.shape; // length 4
    final inputType = inputTensor.type;

    int batch = inputShape[0];
    int h, w, c;
    bool channelsLast = true; // NHWC
    if (inputShape[1] == 3) {
      // NCHW
      channelsLast = false;
      c = inputShape[1];
      h = inputShape[2];
      w = inputShape[3];
    } else {
      // NHWC
      h = inputShape[1];
      w = inputShape[2];
      c = inputShape[3];
    }
    if (batch != 1) {
      throw UnsupportedError('Only batch size 1 is supported. Got batch=$batch');
    }

    // Resize
    final resized = img.copyResize(original, width: w, height: h);

    // Prepare input buffer
    final typeStr = inputType.toString().toLowerCase();
    final isFloat = typeStr.contains('float32');
    final isUint8 = typeStr.contains('uint8');
    if (!isFloat && !isUint8) {
      throw UnsupportedError('Unsupported input type: $inputType');
    }

    dynamic input;
    if (isFloat) {
      // Normalize to [0,1]
      if (channelsLast) {
        input = List.generate(1, (_) =>
            List.generate(h, (y) =>
              List.generate(w, (x) =>
                List.generate(c, (ch) {
                  final p = resized.getPixel(x, y);
                  final r = p.r.toDouble() / 255.0;
                  final g = p.g.toDouble() / 255.0;
                  final b = p.b.toDouble() / 255.0;
                  switch (ch) {
                    case 0: return r;
                    case 1: return g;
                    default: return b;
                  }
                })
              )
            )
        );
      } else {
        // NCHW
        input = List.generate(1, (_) =>
            List.generate(c, (ch) =>
              List.generate(h, (y) =>
                List.generate(w, (x) {
                  final p = resized.getPixel(x, y);
                  switch (ch) {
                    case 0: return p.r.toDouble() / 255.0;
                    case 1: return p.g.toDouble() / 255.0;
                    default: return p.b.toDouble() / 255.0;
                  }
                })
              )
            )
        );
      }
    } else {
      // uint8
      if (channelsLast) {
        input = List.generate(1, (_) =>
            List.generate(h, (y) =>
              List.generate(w, (x) =>
                List.generate(c, (ch) {
                  final p = resized.getPixel(x, y);
                  switch (ch) {
                    case 0: return p.r;
                    case 1: return p.g;
                    default: return p.b;
                  }
                })
              )
            )
        );
      } else {
        input = List.generate(1, (_) =>
            List.generate(c, (ch) =>
              List.generate(h, (y) =>
                List.generate(w, (x) {
                  final p = resized.getPixel(x, y);
                  switch (ch) {
                    case 0: return p.r;
                    case 1: return p.g;
                    default: return p.b;
                  }
                })
              )
            )
        );
      }
    }

    // Prepare output
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outShape = outputTensor.shape; // [1, numClasses] or similar
    int numClasses = outShape.reduce((a, b) => a * b) ~/ 1; // usually 1 * N
    if (outShape.length == 2) {
      numClasses = outShape[1];
    }

    // Allocate output buffer matching tensor type
    final outTypeStr = outputTensor.type.toString().toLowerCase();
    final outIsFloat = outTypeStr.contains('float32');
    final outIsUint8 = outTypeStr.contains('uint8');

    dynamic output;
    if (outIsFloat) {
      output = List.generate(1, (_) => List.filled(numClasses, 0.0));
    } else if (outIsUint8) {
      output = List.generate(1, (_) => List.filled(numClasses, 0));
    } else {
      throw UnsupportedError('Unsupported output type: ${outputTensor.type}');
    }

    // Inference
    _interpreter!.run(input, output);

    // Convert scores to doubles (dequantize if needed)
    List<double> scores;
    if (outIsFloat) {
      scores = (output.first as List).cast<double>();
    } else {
      final ints = (output.first as List).cast<int>();
      // Map uint8 scores (0..255) to [0,1]. This is a safe fallback across tflite_flutter versions.
      scores = List<double>.generate(ints.length, (i) => ints[i] / 255.0);
    }

    int bestIdx = 0;
    double bestScore = -1.0;
    for (int i = 0; i < scores.length; i++) {
      final s = scores[i];
      if (s > bestScore) {
        bestScore = s;
        bestIdx = i;
      }
    }

    String label = (bestIdx < _labels.length) ? _labels[bestIdx] : 'class_$bestIdx';
    // Clamp score to [0,1] when it makes sense (float models / scaled outputs)
    final clamped = bestScore.isFinite ? math.max(0.0, math.min(1.0, bestScore)) : 0.0;
    return ClassificationResult(label, clamped);
  }
}
