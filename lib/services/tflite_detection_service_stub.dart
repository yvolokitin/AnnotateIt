class DetectionResult {
  final String label;
  final double score;
  final List<double>? box;
  DetectionResult({required this.label, required this.score, this.box});
}

class TFLiteDetectionService {
  static const String defaultDetectionModelId = 'efficientdet-tflite-lite4-detection-metadata-v2';
  static const String defaultModelFileName = 'efficientdet-tflite-lite4-detection-metadata-v2.tflite';
  static const String defaultLabelsFileName = 'coco_labels.txt';

  bool get isInitialized => false;

  Future<bool> isModelAvailableInUserFolder({
    String modelId = defaultDetectionModelId,
    String modelFileName = defaultModelFileName,
    String labelsFileName = defaultLabelsFileName,
  }) async => false;

  Future<void> initializeFromUserFolder({
    String modelId = defaultDetectionModelId,
    String modelFileName = defaultModelFileName,
    String labelsFileName = defaultLabelsFileName,
  }) async {
    throw UnsupportedError('TFLite is not supported on web');
  }

  Future<void> initializeFromFiles({
    required String modelFilePath,
    required String labelsFilePath,
  }) async {
    throw UnsupportedError('TFLite is not supported on web');
  }

  Future<void> dispose() async {}

  Future<List<DetectionResult>> detectImage(dynamic file, {double scoreThreshold = 0.30}) async => const [];
}
