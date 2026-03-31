import 'dart:convert';

/// Where the AI inference was executed.
enum AiBackendType {
  /// On-device (TFLite, ML Kit, CoreML, ONNX Runtime, etc.)
  local,

  /// Self-hosted server (private cloud, lab GPU, etc.)
  onprem,

  /// Third-party cloud API (OpenAI, Google Cloud Vision, etc.)
  external,
}

/// How the inference completed.
enum AiFinishReason {
  /// Inference completed normally with a result.
  success,

  /// Inference returned no usable result (empty, below threshold, etc.)
  empty,

  /// Inference timed out.
  timeout,

  /// Inference failed with an error.
  error,

  /// Inference was cancelled by the user.
  cancelled,
}

/// Unified envelope for all AI inference results.
///
/// Wraps any AI/ML output in a standard structure so that consumers
/// (annotation persistence, UI, export) can handle metadata uniformly
/// regardless of the underlying model or backend.
///
/// The [payload] field is generic — callers supply the domain-specific
/// result type (e.g. `OcrResult`, `List<DetectionResult>`, etc.).
class AiResultEnvelope<T> {
  /// Human-readable model name (e.g. "mlkit_text_recognition",
  /// "efficientdet-lite4", "sam2_hiera_base_plus").
  final String modelName;

  /// Model version string (e.g. "mlkit-latin-v1", "1.0.0").
  final String modelVersion;

  /// Where the inference was executed.
  final AiBackendType backendType;

  /// Time spent on model inference only (ms). -1 if not measured.
  final int inferenceLatencyMs;

  /// Total wall-clock time including pre/post-processing (ms). -1 if not measured.
  final int totalLatencyMs;

  /// How the inference completed.
  final AiFinishReason finishReason;

  /// The domain-specific result. `null` when [finishReason] is not [AiFinishReason.success].
  final T? payload;

  /// Free-form provenance metadata (source image path, run ID, etc.).
  final Map<String, dynamic> provenance;

  /// Optional human-readable error message when [finishReason] is [AiFinishReason.error].
  final String? errorMessage;

  const AiResultEnvelope({
    required this.modelName,
    required this.modelVersion,
    required this.backendType,
    this.inferenceLatencyMs = -1,
    this.totalLatencyMs = -1,
    required this.finishReason,
    this.payload,
    this.provenance = const {},
    this.errorMessage,
  });

  bool get isSuccess => finishReason == AiFinishReason.success;
  bool get hasPayload => payload != null;

  // -- Factories --------------------------------------------------------------

  /// Convenience for a successful result.
  factory AiResultEnvelope.success({
    required String modelName,
    required String modelVersion,
    AiBackendType backendType = AiBackendType.local,
    int inferenceLatencyMs = -1,
    int totalLatencyMs = -1,
    required T payload,
    Map<String, dynamic> provenance = const {},
  }) {
    return AiResultEnvelope(
      modelName: modelName,
      modelVersion: modelVersion,
      backendType: backendType,
      inferenceLatencyMs: inferenceLatencyMs,
      totalLatencyMs: totalLatencyMs,
      finishReason: AiFinishReason.success,
      payload: payload,
      provenance: provenance,
    );
  }

  /// Convenience for a failed result.
  factory AiResultEnvelope.error({
    required String modelName,
    required String modelVersion,
    AiBackendType backendType = AiBackendType.local,
    int totalLatencyMs = -1,
    required String errorMessage,
    Map<String, dynamic> provenance = const {},
  }) {
    return AiResultEnvelope(
      modelName: modelName,
      modelVersion: modelVersion,
      backendType: backendType,
      totalLatencyMs: totalLatencyMs,
      finishReason: AiFinishReason.error,
      errorMessage: errorMessage,
      provenance: provenance,
    );
  }

  /// Convenience for an empty/no-result outcome.
  factory AiResultEnvelope.empty({
    required String modelName,
    required String modelVersion,
    AiBackendType backendType = AiBackendType.local,
    int totalLatencyMs = -1,
    Map<String, dynamic> provenance = const {},
  }) {
    return AiResultEnvelope(
      modelName: modelName,
      modelVersion: modelVersion,
      backendType: backendType,
      totalLatencyMs: totalLatencyMs,
      finishReason: AiFinishReason.empty,
      provenance: provenance,
    );
  }

  // -- Serialisation ----------------------------------------------------------

  /// Serialise the envelope metadata (without the typed payload) to a map
  /// suitable for storing as JSON in annotation provenance fields.
  Map<String, dynamic> toMetadataMap() => {
    'modelName': modelName,
    'modelVersion': modelVersion,
    'backendType': backendType.name,
    'inferenceLatencyMs': inferenceLatencyMs,
    'totalLatencyMs': totalLatencyMs,
    'finishReason': finishReason.name,
    if (errorMessage != null) 'errorMessage': errorMessage,
    if (provenance.isNotEmpty) 'provenance': provenance,
  };

  String toMetadataJson() => jsonEncode(toMetadataMap());

  /// Reconstruct envelope metadata from a map (payload must be supplied
  /// separately since it is generic).
  static AiResultEnvelope<T> fromMetadataMap<T>(
    Map<String, dynamic> map, {
    T? payload,
  }) {
    return AiResultEnvelope<T>(
      modelName: map['modelName'] as String? ?? '',
      modelVersion: map['modelVersion'] as String? ?? '',
      backendType: _parseBackendType(map['backendType'] as String?),
      inferenceLatencyMs: (map['inferenceLatencyMs'] as num?)?.toInt() ?? -1,
      totalLatencyMs: (map['totalLatencyMs'] as num?)?.toInt() ?? -1,
      finishReason: _parseFinishReason(map['finishReason'] as String?),
      payload: payload,
      provenance: (map['provenance'] as Map<String, dynamic>?) ?? const {},
      errorMessage: map['errorMessage'] as String?,
    );
  }

  static AiBackendType _parseBackendType(String? raw) {
    if (raw == null) return AiBackendType.local;
    return AiBackendType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => AiBackendType.local,
    );
  }

  static AiFinishReason _parseFinishReason(String? raw) {
    if (raw == null) return AiFinishReason.success;
    return AiFinishReason.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => AiFinishReason.success,
    );
  }

  // -- Helpers ----------------------------------------------------------------

  AiResultEnvelope<T> copyWith({
    String? modelName,
    String? modelVersion,
    AiBackendType? backendType,
    int? inferenceLatencyMs,
    int? totalLatencyMs,
    AiFinishReason? finishReason,
    T? payload,
    Map<String, dynamic>? provenance,
    String? errorMessage,
  }) {
    return AiResultEnvelope<T>(
      modelName: modelName ?? this.modelName,
      modelVersion: modelVersion ?? this.modelVersion,
      backendType: backendType ?? this.backendType,
      inferenceLatencyMs: inferenceLatencyMs ?? this.inferenceLatencyMs,
      totalLatencyMs: totalLatencyMs ?? this.totalLatencyMs,
      finishReason: finishReason ?? this.finishReason,
      payload: payload ?? this.payload,
      provenance: provenance ?? this.provenance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'AiResultEnvelope('
      'model=$modelName@$modelVersion, '
      'backend=${backendType.name}, '
      'finish=${finishReason.name}, '
      'inference=${inferenceLatencyMs}ms, '
      'total=${totalLatencyMs}ms'
      ')';
}
