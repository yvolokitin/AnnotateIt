import 'dart:async';

/// Inference mode controlling how the stream processes frames.
enum StreamInferenceMode {
  /// Object detection (bounding boxes).
  detection,

  /// Image classification (labels + confidence).
  classification,

  /// Optical character recognition.
  ocr,

  /// Instance/semantic segmentation.
  segmentation,

  /// Custom / prompt-driven inference (e.g. VLM, LLM-vision).
  custom,
}

/// A single result emitted by a running inference stream.
class StreamInferenceResult {
  /// Unique identifier of the stream that produced this result.
  final String streamId;

  /// Monotonically increasing sequence number within the stream.
  final int sequenceNumber;

  /// ISO-8601 timestamp when the result was produced.
  final DateTime timestamp;

  /// The inference output — structure depends on [StreamInferenceMode].
  ///
  /// For `detection`: `List<Map>` of bounding boxes.
  /// For `classification`: `List<Map>` of label/confidence pairs.
  /// For `ocr`: `Map` with `text`, `blocks`, etc.
  /// For `segmentation`: `Map` with mask data.
  /// For `custom`: arbitrary JSON-encodable object.
  final dynamic payload;

  /// Inference latency in milliseconds for this frame/chunk.
  final int latencyMs;

  const StreamInferenceResult({
    required this.streamId,
    required this.sequenceNumber,
    required this.timestamp,
    required this.payload,
    this.latencyMs = 0,
  });

  @override
  String toString() =>
      'StreamInferenceResult(stream=$streamId, seq=$sequenceNumber, '
      'latency=${latencyMs}ms)';
}

/// Schema definition for structured output from custom/prompt-driven modes.
///
/// Acts as a lightweight JSON-Schema-like contract that the inference
/// backend should try to conform its output to.
class StreamOutputSchema {
  final String name;
  final Map<String, dynamic> fields;

  const StreamOutputSchema({required this.name, required this.fields});

  Map<String, dynamic> toMap() => {'name': name, 'fields': fields};

  factory StreamOutputSchema.fromMap(Map<String, dynamic> map) {
    return StreamOutputSchema(
      name: map['name'] as String,
      fields: Map<String, dynamic>.from(map['fields'] as Map),
    );
  }
}

/// Configuration for starting a new inference stream.
class StreamInferenceConfig {
  /// Opaque source identifier (camera ID, video file path, RTSP URL, etc.)
  final String source;

  final StreamInferenceMode mode;

  /// Optional natural-language prompt (primarily for [StreamInferenceMode.custom]).
  final String? prompt;

  /// Optional output schema the backend should conform to.
  final StreamOutputSchema? schema;

  const StreamInferenceConfig({
    required this.source,
    required this.mode,
    this.prompt,
    this.schema,
  });
}

/// Port (interface) for real-time / streaming AI inference.
///
/// Implementations may connect to an on-device model pipeline, a remote
/// GPU server, or a cloud-hosted vision API. The contract is intentionally
/// transport-agnostic so adapters can be swapped without touching consumers.
abstract class StreamInferencePort {
  /// Start a new inference stream and return its unique ID.
  ///
  /// The stream begins consuming frames from [config.source] immediately
  /// and results become available via [subscribeResults].
  Future<String> startStream(StreamInferenceConfig config);

  /// Hot-swap the prompt on a running stream (no restart needed).
  ///
  /// Only meaningful for modes that accept prompts (e.g. [StreamInferenceMode.custom]).
  /// Implementations that don't support prompt updates should ignore silently.
  Future<void> updatePrompt(String streamId, String prompt);

  /// Subscribe to the result stream for a given [streamId].
  ///
  /// Returns a broadcast [Stream] that emits [StreamInferenceResult]s
  /// as they are produced. The stream closes when [stopStream] is called
  /// or the source is exhausted.
  Stream<StreamInferenceResult> subscribeResults(String streamId);

  /// Gracefully stop a running stream and release its resources.
  ///
  /// After this call, [subscribeResults] for the same ID will complete.
  /// Calling stop on an already-stopped or unknown stream is a no-op.
  Future<void> stopStream(String streamId);

  /// List IDs of all currently active streams.
  Future<List<String>> activeStreams();
}
