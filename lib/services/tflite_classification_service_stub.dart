class ClassificationResult {
  final String label;
  final double score;
  ClassificationResult(this.label, this.score);
}

class TFLiteClassificationService {
  static const String defaultClassificationModelId = 'classification_efficientnet-tflite-lite0-int8-v2';

  bool get isInitialized => false;

  Future<bool> isModelAvailableInUserFolder({
    String modelId = defaultClassificationModelId,
    String? modelFileName,
    String? labelsFileName,
  }) async => false;

  Future<void> initializeFromUserFolder({
    String modelId = defaultClassificationModelId,
    String? modelFileName,
    String? labelsFileName,
  }) async {
    throw UnsupportedError('TFLite is not supported on web');
  }

  Future<void> dispose() async {}

  Future<void> initialize({
    String modelAssetPath = 'assets/models/classification.tflite',
    String labelsAssetPath = 'assets/models/ssd_mobilenet_labels.txt',
  }) async {
    throw UnsupportedError('TFLite is not supported on web');
  }

  Future<void> initializeFromFiles({
    required String modelFilePath,
    required String labelsFilePath,
  }) async {
    throw UnsupportedError('TFLite is not supported on web');
  }

  Future<ClassificationResult?> classifyImage(dynamic file, {int topK = 1}) async => null;

  Future<List<ClassificationResult>> classifyImageMulti(
    dynamic file, {
    double confidenceThreshold = 0.6,
    int maxResults = 10,
  }) async => [];
}
