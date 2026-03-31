import 'dart:async';
import 'dart:math';

import 'package:logging/logging.dart';

import 'stream_inference_port.dart';

final _log = Logger('MockStreamInference');

/// Mock adapter that emits synthetic results at a configurable interval.
///
/// Useful for UI development and integration testing without a real
/// inference backend. Each stream emits incrementing detection/classification
/// results until stopped.
class MockStreamInferenceAdapter implements StreamInferencePort {
  final Duration emitInterval;
  final Random _random;

  final Map<String, _MockStream> _streams = {};

  MockStreamInferenceAdapter({
    this.emitInterval = const Duration(milliseconds: 500),
    Random? random,
  }) : _random = random ?? Random.secure();

  @override
  Future<String> startStream(StreamInferenceConfig config) async {
    final id = _generateId();
    final controller = StreamController<StreamInferenceResult>.broadcast();

    var seq = 0;
    String? currentPrompt = config.prompt;

    final timer = Timer.periodic(emitInterval, (_) {
      if (controller.isClosed) return;
      seq++;
      controller.add(StreamInferenceResult(
        streamId: id,
        sequenceNumber: seq,
        timestamp: DateTime.now(),
        latencyMs: 10 + _random.nextInt(40),
        payload: _syntheticPayload(config.mode, seq, currentPrompt),
      ));
    });

    _streams[id] = _MockStream(
      controller: controller,
      timer: timer,
      config: config,
      setPrompt: (p) => currentPrompt = p,
    );

    _log.fine(
      'Mock stream $id started '
      '(source=${config.source}, mode=${config.mode.name})',
    );
    return id;
  }

  @override
  Future<void> updatePrompt(String streamId, String prompt) async {
    final mock = _streams[streamId];
    if (mock == null) return;
    mock.setPrompt(prompt);
    _log.fine('Mock stream $streamId prompt updated to "$prompt"');
  }

  @override
  Stream<StreamInferenceResult> subscribeResults(String streamId) {
    final mock = _streams[streamId];
    if (mock == null) return const Stream.empty();
    return mock.controller.stream;
  }

  @override
  Future<void> stopStream(String streamId) async {
    final mock = _streams.remove(streamId);
    if (mock != null) {
      mock.timer.cancel();
      await mock.controller.close();
      _log.fine('Mock stream $streamId stopped');
    }
  }

  @override
  Future<List<String>> activeStreams() async {
    return _streams.keys.toList();
  }

  Map<String, dynamic> _syntheticPayload(
    StreamInferenceMode mode,
    int seq,
    String? prompt,
  ) {
    switch (mode) {
      case StreamInferenceMode.detection:
        return {
          'detections': [
            {
              'label': 'object_$seq',
              'confidence': 0.85 + _random.nextDouble() * 0.14,
              'bbox': {
                'x': _random.nextDouble() * 0.5,
                'y': _random.nextDouble() * 0.5,
                'width': 0.1 + _random.nextDouble() * 0.3,
                'height': 0.1 + _random.nextDouble() * 0.3,
              },
            },
          ],
        };
      case StreamInferenceMode.classification:
        return {
          'labels': [
            {'label': 'class_a', 'confidence': 0.7 + _random.nextDouble() * 0.3},
            {'label': 'class_b', 'confidence': 0.1 + _random.nextDouble() * 0.2},
          ],
        };
      case StreamInferenceMode.ocr:
        return {
          'text': 'Sample text frame $seq',
          'blocks': [
            {'text': 'Sample', 'rect': {'x': 10, 'y': 20, 'w': 100, 'h': 30}},
          ],
        };
      case StreamInferenceMode.segmentation:
        return {
          'mask_width': 640,
          'mask_height': 480,
          'classes': ['background', 'person'],
          'dominant_class': 'person',
        };
      case StreamInferenceMode.custom:
        return {
          'prompt': prompt ?? '',
          'response': 'Mock response #$seq for prompt: ${prompt ?? "none"}',
        };
    }
  }

  String _generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final salt = _random.nextInt(1 << 16).toRadixString(16).padLeft(4, '0');
    return 'mock_${ts}_$salt';
  }
}

class _MockStream {
  final StreamController<StreamInferenceResult> controller;
  final Timer timer;
  final StreamInferenceConfig config;
  final void Function(String) setPrompt;

  const _MockStream({
    required this.controller,
    required this.timer,
    required this.config,
    required this.setPrompt,
  });
}
