import 'dart:async';
import 'dart:math';

import 'package:logging/logging.dart';

import '../models/ai_result_envelope.dart';
import 'api_key_provider.dart';
import 'stream_inference_port.dart';

final _log = Logger('ExternalStreamAdapter');

/// Adapter that connects to an external (cloud) inference API,
/// implementing [StreamInferencePort].
///
/// When no API key is available, the adapter degrades gracefully:
/// [startStream] throws [MissingApiKeyException] instead of silently
/// failing, so consumers can fall back to a local or no-op adapter.
///
/// Internally simulates a WebSocket-like polling loop that calls the
/// external endpoint and maps responses into the unified
/// [AiResultEnvelope] and [StreamInferenceResult] types.
class ExternalStreamAdapter implements StreamInferencePort {
  final ApiKeyProvider _keyProvider;
  final String serviceName;
  final String baseUrl;
  final Duration pollInterval;
  final Duration keepAliveInterval;

  /// Pluggable HTTP caller — accepts (url, headers, body) and returns
  /// the response body as a parsed JSON map. Override for testing.
  final Future<Map<String, dynamic>> Function(
    String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) httpPost;

  final Map<String, _ExternalStream> _streams = {};
  final Random _random;

  ExternalStreamAdapter({
    required ApiKeyProvider keyProvider,
    this.serviceName = 'external_inference',
    this.baseUrl = 'https://api.example.com/v1/inference',
    this.pollInterval = const Duration(milliseconds: 500),
    this.keepAliveInterval = const Duration(seconds: 30),
    Future<Map<String, dynamic>> Function(
      String url,
      Map<String, String> headers,
      Map<String, dynamic> body,
    )? httpPost,
    Random? random,
  })  : _keyProvider = keyProvider,
        httpPost = httpPost ?? _defaultHttpPost,
        _random = random ?? Random.secure();

  // -- StreamInferencePort ----------------------------------------------------

  @override
  Future<String> startStream(StreamInferenceConfig config) async {
    final apiKey = await _keyProvider.getApiKey(serviceName);
    if (apiKey == null || apiKey.isEmpty) {
      _log.warning('No API key for "$serviceName" — degrading');
      throw MissingApiKeyException(serviceName);
    }

    final streamId = _generateId();
    final controller = StreamController<StreamInferenceResult>.broadcast();

    Map<String, dynamic> createBody = {
      'source': config.source,
      'mode': config.mode.name,
      if (config.prompt != null) 'prompt': config.prompt,
      if (config.schema != null) 'schema': config.schema!.toMap(),
    };

    String? remoteStreamId;
    try {
      final response = await httpPost(
        '$baseUrl/streams',
        _authHeaders(apiKey),
        createBody,
      );
      remoteStreamId = response['stream_id'] as String?;
      _log.info(
        'External stream created: local=$streamId remote=$remoteStreamId',
      );
    } catch (e) {
      _log.severe('Failed to create external stream', e);
      await controller.close();
      rethrow;
    }

    var seq = 0;
    String? currentPrompt = config.prompt;

    final pollTimer = Timer.periodic(pollInterval, (_) async {
      if (controller.isClosed) return;
      try {
        final ts = DateTime.now();
        final response = await httpPost(
          '$baseUrl/streams/$remoteStreamId/results',
          _authHeaders(apiKey),
          {'prompt': currentPrompt},
        );

        final envelope = mapResponseToEnvelope(response);
        final latency = DateTime.now().difference(ts).inMilliseconds;

        seq++;
        controller.add(StreamInferenceResult(
          streamId: streamId,
          sequenceNumber: seq,
          timestamp: DateTime.now(),
          latencyMs: latency,
          payload: {
            ...?_payloadAsMap(envelope.payload),
            '_envelope': envelope.toMetadataMap(),
          },
        ));
      } catch (e) {
        _log.fine('Poll error on $streamId: $e');
      }
    });

    final keepAliveTimer = Timer.periodic(keepAliveInterval, (_) async {
      if (controller.isClosed) return;
      try {
        await httpPost(
          '$baseUrl/streams/$remoteStreamId/keepalive',
          _authHeaders(apiKey),
          {},
        );
      } catch (e) {
        _log.fine('Keep-alive error on $streamId: $e');
      }
    });

    _streams[streamId] = _ExternalStream(
      controller: controller,
      pollTimer: pollTimer,
      keepAliveTimer: keepAliveTimer,
      remoteStreamId: remoteStreamId ?? streamId,
      apiKey: apiKey,
      config: config,
      setPrompt: (p) => currentPrompt = p,
    );

    return streamId;
  }

  @override
  Future<void> updatePrompt(String streamId, String prompt) async {
    final stream = _streams[streamId];
    if (stream == null) return;
    stream.setPrompt(prompt);

    try {
      await httpPost(
        '$baseUrl/streams/${stream.remoteStreamId}/prompt',
        _authHeaders(stream.apiKey),
        {'prompt': prompt},
      );
      _log.fine('Prompt updated on external stream $streamId');
    } catch (e) {
      _log.fine('Prompt update failed (local update still applied): $e');
    }
  }

  @override
  Stream<StreamInferenceResult> subscribeResults(String streamId) {
    final stream = _streams[streamId];
    if (stream == null) return const Stream.empty();
    return stream.controller.stream;
  }

  @override
  Future<void> stopStream(String streamId) async {
    final stream = _streams.remove(streamId);
    if (stream == null) return;

    stream.pollTimer.cancel();
    stream.keepAliveTimer.cancel();
    await stream.controller.close();

    try {
      await httpPost(
        '$baseUrl/streams/${stream.remoteStreamId}/stop',
        _authHeaders(stream.apiKey),
        {},
      );
    } catch (e) {
      _log.fine('Failed to stop remote stream ${stream.remoteStreamId}: $e');
    }

    _log.fine('External stream $streamId stopped');
  }

  @override
  Future<List<String>> activeStreams() async => _streams.keys.toList();

  // -- Response mapping -------------------------------------------------------

  /// Maps a raw external API response into the unified [AiResultEnvelope].
  ///
  /// External APIs typically return:
  /// ```json
  /// { "model": "...", "version": "...", "status": "success|error|empty",
  ///   "result": { ... }, "latency_ms": 42, "error": "..." }
  /// ```
  AiResultEnvelope<Map<String, dynamic>> mapResponseToEnvelope(
    Map<String, dynamic> response,
  ) {
    final model = response['model'] as String? ?? serviceName;
    final version = response['version'] as String? ?? 'unknown';
    final status = response['status'] as String? ?? 'success';
    final latency = (response['latency_ms'] as num?)?.toInt() ?? -1;
    final result = response['result'] as Map<String, dynamic>?;
    final error = response['error'] as String?;

    switch (status) {
      case 'error':
        return AiResultEnvelope.error(
          modelName: model,
          modelVersion: version,
          backendType: AiBackendType.external,
          totalLatencyMs: latency,
          errorMessage: error ?? 'Unknown external error',
          provenance: {'service': serviceName},
        );
      case 'empty':
        return AiResultEnvelope.empty(
          modelName: model,
          modelVersion: version,
          backendType: AiBackendType.external,
          totalLatencyMs: latency,
          provenance: {'service': serviceName},
        );
      default:
        return AiResultEnvelope.success(
          modelName: model,
          modelVersion: version,
          backendType: AiBackendType.external,
          inferenceLatencyMs: latency,
          totalLatencyMs: latency,
          payload: result ?? {},
          provenance: {'service': serviceName},
        );
    }
  }

  // -- Helpers ----------------------------------------------------------------

  Map<String, String> _authHeaders(String apiKey) => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  Map<String, dynamic>? _payloadAsMap(dynamic payload) {
    if (payload is Map<String, dynamic>) return payload;
    return null;
  }

  String _generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final salt = _random.nextInt(1 << 16).toRadixString(16).padLeft(4, '0');
    return 'ext_${ts}_$salt';
  }

  static Future<Map<String, dynamic>> _defaultHttpPost(
    String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    throw UnimplementedError(
      'No HTTP client configured. Provide an httpPost function '
      'or use a concrete subclass.',
    );
  }
}

/// Thrown when [ExternalStreamAdapter.startStream] is called but no
/// API key is available for the configured service.
class MissingApiKeyException implements Exception {
  final String service;
  const MissingApiKeyException(this.service);

  @override
  String toString() =>
      'MissingApiKeyException: No API key configured for "$service". '
      'Set ${service.toUpperCase()}_API_KEY or configure a key provider.';
}

class _ExternalStream {
  final StreamController<StreamInferenceResult> controller;
  final Timer pollTimer;
  final Timer keepAliveTimer;
  final String remoteStreamId;
  final String apiKey;
  final StreamInferenceConfig config;
  final void Function(String) setPrompt;

  const _ExternalStream({
    required this.controller,
    required this.pollTimer,
    required this.keepAliveTimer,
    required this.remoteStreamId,
    required this.apiKey,
    required this.config,
    required this.setPrompt,
  });
}
