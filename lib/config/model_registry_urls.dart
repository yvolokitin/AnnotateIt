import 'app_runtime_config.dart';

class ModelRegistryUrls {
  static const String _defaultBaseUrl =
      'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large';

  static String get _baseUrl {
    final configured = AppRuntimeConfig.instance.modelRegistryBaseUrl;
    if (configured.isNotEmpty) {
      return configured;
    }
    if (!AppRuntimeConfig.instance.allowExternalModelDownloads) {
      return '';
    }
    return _defaultBaseUrl;
  }

  static String _resolve(String fileName) {
    if (_baseUrl.isEmpty) return '';
    return '$_baseUrl/$fileName';
  }

  static String get sam2HieraBasePlusEncoder =>
      _resolve('sam2_hiera_base_plus.encoder.onnx');
  static String get sam2HieraBasePlusDecoder =>
      _resolve('sam2_hiera_base_plus.decoder.onnx');
  static String get sam2HieraBasePlusConfig =>
      _resolve('sam2_hiera_base_plus_config.yaml');

  static String get sam2HieraLargeEncoder =>
      _resolve('sam2_hiera_large.encoder.onnx');
  static String get sam2HieraLargeDecoder =>
      _resolve('sam2_hiera_large.decoder.onnx');
  static String get sam2HieraLargeConfig =>
      _resolve('sam2_hiera_large_config.yaml');

  static String get efficientNetLite4Classifier =>
      _resolve('efficientnet-tflite-lite4-fp32-v2.tflite');
  static String get efficientNetLite4ClassifierLabels =>
      _resolve('classification_efficientnet-tflite-lite0-int8-v2_labels.txt');

  static String get efficientDetLite4Detector =>
      _resolve('efficientdet-tflite-lite4-detection-metadata-v2.tflite');
  static String get cocoLabels => _resolve('coco_labels.txt');
}
