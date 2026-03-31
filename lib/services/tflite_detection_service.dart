import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/ai_result_envelope.dart';
import '../session/user_session.dart';

class DetectionResult {
  final String label;
  final double score;
  // Normalized box [ymin, xmin, ymax, xmax] in 0..1, if available
  final List<double>? box;
  DetectionResult({required this.label, required this.score, this.box});
}

class TFLiteDetectionService {
  static const String defaultDetectionModelId = 'efficientdet-tflite-lite4-detection-metadata-v2';
  static const String defaultModelFileName = 'efficientdet-tflite-lite4-detection-metadata-v2.tflite';
  static const String defaultLabelsFileName = 'coco_labels.txt';

  final _log = Logger('TFLiteDetectionService');

  Interpreter? _interpreter;
  List<String> _labels = const [];

  bool get isInitialized => _interpreter != null && _labels.isNotEmpty;

  Future<String> _modelsRoot() async {
    try {
      return await UserSession.instance.getCurrentUserModelsFolder();
    } catch (_) {
      final dir = await getApplicationDocumentsDirectory();
      return p.join(dir.path, 'AnnotateIt', 'models');
    }
  }

  Future<bool> isModelAvailableInUserFolder({
    String modelId = defaultDetectionModelId,
    String modelFileName = defaultModelFileName,
    String labelsFileName = defaultLabelsFileName,
  }) async {
    final root = await _modelsRoot();
    final folder = Directory(p.join(root, modelId));
    if (!await folder.exists()) return false;
    final model = File(p.join(root, modelId, modelFileName));
    final labels = File(p.join(root, modelId, labelsFileName));
    final modelOk = await model.exists() && (await model.length()) > 1024;
    final labelsOk = await labels.exists() && (await labels.length()) > 0;
    return modelOk && labelsOk;
  }

  Future<void> initializeFromUserFolder({
    String modelId = defaultDetectionModelId,
    String modelFileName = defaultModelFileName,
    String labelsFileName = defaultLabelsFileName,
  }) async {
    final root = await _modelsRoot();
    final modelPath = p.join(root, modelId, modelFileName);
    final labelsPath = p.join(root, modelId, labelsFileName);

    final model = File(modelPath);
    final labels = File(labelsPath);
    if (!await model.exists() || !await labels.exists()) {
      throw Exception('TFLite detection model not found in user models folder. Please download it from the Model screen.');
    }
    await initializeFromFiles(modelFilePath: modelPath, labelsFilePath: labelsPath);
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
      // Configure interpreter with multiple threads to improve performance
      final cpuCount = Platform.numberOfProcessors;
      int threads = cpuCount > 4 ? 4 : (cpuCount - 1);
      if (threads < 1) threads = 1;
      final options = InterpreterOptions()..threads = threads;
      _interpreter = Interpreter.fromFile(File(modelFilePath), options: options);
      _log.info('TFLite detection model loaded from file: $modelFilePath (threads=$threads)');
    } catch (e) {
      _log.warning('Failed to load detection model from file ($modelFilePath): $e');
      final msg = e.toString();
      if (Platform.isWindows && (msg.contains('libtensorflowlite_c-win') || msg.contains('Failed to load dynamic library'))) {
        throw Exception('TensorFlow Lite runtime is missing on Windows. Please reinstall the app or ensure libtensorflowlite_c-win.dll is present next to the executable or in the "blobs" subfolder. See TFLITE_MODEL_SETUP.md for details.');
      }
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      _interpreter?.close();
    } catch (_) {}
    _interpreter = null;
  }

  Future<List<DetectionResult>> detectImage(File file, {double scoreThreshold = 0.30}) async {
    if (_interpreter == null) return const [];

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return const [];

    // Prepare input based on model input tensor shape and type
    final inputTensor = _interpreter!.getInputTensor(0);
    final inputShape = inputTensor.shape; // [1, H, W, 3] or [1, 3, H, W]
    final inputType = inputTensor.type.toString().toLowerCase();

    int batch = inputShape[0];
    if (batch != 1) {
      throw UnsupportedError('Only batch size 1 is supported for detection.');
    }
    int h, w, c;
    bool channelsLast = true; // NHWC by default
    if (inputShape.length == 4 && inputShape[1] == 3) {
      // NCHW
      channelsLast = false;
      c = inputShape[1];
      h = inputShape[2];
      w = inputShape[3];
    } else {
      h = inputShape[1];
      w = inputShape[2];
      c = inputShape[3];
    }

    final resized = img.copyResize(decoded, width: w, height: h);

    final isFloat = inputType.contains('float32');
    final isUint8 = inputType.contains('uint8');
    if (!isFloat && !isUint8) {
      throw UnsupportedError('Unsupported detection input type: ${inputTensor.type}');
    }

    dynamic input;
    if (isFloat) {
      if (channelsLast) {
        // NHWC float32
        final data = List.generate(1, (_) => List.generate(h, (_) => List.generate(w, (_) => List<double>.filled(c, 0.0, growable: false), growable: false), growable: false), growable: false);
        for (int y = 0; y < h; y++) {
          for (int x = 0; x < w; x++) {
            final px = resized.getPixel(x, y);
            final r = px.r.toDouble() / 255.0;
            final g = px.g.toDouble() / 255.0;
            final b = px.b.toDouble() / 255.0;
            data[0][y][x][0] = r;
            if (c > 1) data[0][y][x][1] = g;
            if (c > 2) data[0][y][x][2] = b;
          }
        }
        input = data;
      } else {
        // NCHW float32
        final data = List.generate(1, (_) => List.generate(c, (_) => List.generate(h, (_) => List<double>.filled(w, 0.0, growable: false), growable: false), growable: false), growable: false);
        for (int y = 0; y < h; y++) {
          for (int x = 0; x < w; x++) {
            final px = resized.getPixel(x, y);
            data[0][0][y][x] = px.r.toDouble() / 255.0;
            if (c > 1) data[0][1][y][x] = px.g.toDouble() / 255.0;
            if (c > 2) data[0][2][y][x] = px.b.toDouble() / 255.0;
          }
        }
        input = data;
      }
    } else {
      if (channelsLast) {
        // NHWC uint8
        final data = List.generate(1, (_) => List.generate(h, (_) => List.generate(w, (_) => List<int>.filled(c, 0, growable: false), growable: false), growable: false), growable: false);
        for (int y = 0; y < h; y++) {
          for (int x = 0; x < w; x++) {
            final px = resized.getPixel(x, y);
            data[0][y][x][0] = px.r.toInt();
            if (c > 1) data[0][y][x][1] = px.g.toInt();
            if (c > 2) data[0][y][x][2] = px.b.toInt();
          }
        }
        input = data;
      } else {
        // NCHW uint8
        final data = List.generate(1, (_) => List.generate(c, (_) => List.generate(h, (_) => List<int>.filled(w, 0, growable: false), growable: false), growable: false), growable: false);
        for (int y = 0; y < h; y++) {
          for (int x = 0; x < w; x++) {
            final px = resized.getPixel(x, y);
            data[0][0][y][x] = px.r.toInt();
            if (c > 1) data[0][1][y][x] = px.g.toInt();
            if (c > 2) data[0][2][y][x] = px.b.toInt();
          }
        }
        input = data;
      }
    }

    // Prepare outputs. Typical TFLite detection models expose 4 outputs:
    // 0: boxes [1, num, 4]; 1: classes [1, num]; 2: scores [1, num]; 3: count [1]
    // We'll attempt to allocate accordingly based on shapes.
    final out0 = _interpreter!.getOutputTensor(0);
    final out1 = _interpreter!.getOutputTensor(1);
    final out2 = _interpreter!.getOutputTensor(2);
    // count may not exist in some models; handle cautiously
    Tensor? out3;
    try { out3 = _interpreter!.getOutputTensor(3); } catch (_) { out3 = null; }

    List<List<List<double>>> boxes;
    List<List<double>> classes;
    List<List<double>> scores;
    List<double> count = [0];

    int numDetections;

    // Helper to allocate float output buffers
    dynamic _allocFor(Tensor t, List<int> shape) {
      final type = t.type.toString().toLowerCase();
      final isF = type.contains('float32');
      if (shape.length == 3) {
        // [1, num, 4]
        if (isF) return List.generate(shape[0], (_) => List.generate(shape[1], (_) => List.filled(shape[2], 0.0)));
        return List.generate(shape[0], (_) => List.generate(shape[1], (_) => List.filled(shape[2], 0)));
      } else if (shape.length == 2) {
        if (isF) return List.generate(shape[0], (_) => List.filled(shape[1], 0.0));
        return List.generate(shape[0], (_) => List.filled(shape[1], 0));
      } else {
        if (isF) return List.filled(shape.reduce((a,b)=>a*b), 0.0);
        return List.filled(shape.reduce((a,b)=>a*b), 0);
      }
    }

    final boxesShape = out0.shape; // [1, N, 4]
    final classesShape = out1.shape; // [1, N]
    final scoresShape = out2.shape; // [1, N]
    final boxesBuf = _allocFor(out0, boxesShape);
    final classesBuf = _allocFor(out1, classesShape);
    final scoresBuf = _allocFor(out2, scoresShape);
    dynamic countBuf;
    if (out3 != null) {
      countBuf = _allocFor(out3, out3.shape);
    }

    final Map<int, Object> outputs = {
      0: boxesBuf,
      1: classesBuf,
      2: scoresBuf,
    };
    if (out3 != null) {
      outputs[3] = countBuf;
    }

    _interpreter!.runForMultipleInputs([input], outputs);

    // Extract outputs as doubles
    // boxes: List<List<List<num>>> shape [1][N][4]
    final boxesList = (boxesBuf as List)[0] as List;
    final classesList = (classesBuf as List)[0] as List;
    final scoresList = (scoresBuf as List)[0] as List;
    numDetections = scoresList.length;
    if (out3 != null) {
      // Some models provide an explicit count
      if (countBuf is List && countBuf.isNotEmpty) {
        final raw = countBuf is List<double> ? countBuf[0] : (countBuf[0] as num).toDouble();
        int n = raw.round();
        if (n < 0) n = 0;
        if (n > scoresList.length) n = scoresList.length;
        numDetections = n;
      }
    }

    final results = <DetectionResult>[];
    for (int i = 0; i < numDetections; i++) {
      final score = (scoresList[i] as num).toDouble();
      if (score < scoreThreshold) continue;
      final clsIdxNum = classesList[i] as num;
      int clsIdx = clsIdxNum.round();
      // Some models use 1-based class indexing; adjust if out-of-range
      if (clsIdx < 0 || clsIdx >= _labels.length) {
        if (clsIdx - 1 >= 0 && clsIdx - 1 < _labels.length) {
          clsIdx = clsIdx - 1;
        }
      }
      final label = (clsIdx >= 0 && clsIdx < _labels.length) ? _labels[clsIdx] : 'class_$clsIdx';
      List<double>? box;
      if (boxesList[i] is List && (boxesList[i] as List).length == 4) {
        final b = boxesList[i] as List;
        box = [
          (b[0] as num).toDouble(),
          (b[1] as num).toDouble(),
          (b[2] as num).toDouble(),
          (b[3] as num).toDouble(),
        ];
      }
      results.add(DetectionResult(label: label, score: score, box: box));
    }

    return results;
  }

  /// Runs detection and wraps the result in an [AiResultEnvelope].
  Future<AiResultEnvelope<List<DetectionResult>>> detectImageWithEnvelope(
    File file, {
    double scoreThreshold = 0.30,
    String modelId = defaultDetectionModelId,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final results = await detectImage(file, scoreThreshold: scoreThreshold);
      sw.stop();

      if (results.isEmpty) {
        return AiResultEnvelope.empty(
          modelName: modelId,
          modelVersion: '1.0',
          totalLatencyMs: sw.elapsedMilliseconds,
          provenance: {'sourceFile': file.path},
        );
      }

      return AiResultEnvelope.success(
        modelName: modelId,
        modelVersion: '1.0',
        inferenceLatencyMs: sw.elapsedMilliseconds,
        totalLatencyMs: sw.elapsedMilliseconds,
        payload: results,
        provenance: {'sourceFile': file.path},
      );
    } catch (e) {
      sw.stop();
      return AiResultEnvelope.error(
        modelName: modelId,
        modelVersion: '1.0',
        totalLatencyMs: sw.elapsedMilliseconds,
        errorMessage: e.toString(),
        provenance: {'sourceFile': file.path},
      );
    }
  }
}
