import 'dart:async';
import 'dart:math';

import 'package:logging/logging.dart';

import 'stream_inference_port.dart';

final _log = Logger('LocalNoOpStreamInference');

/// A no-op adapter that accepts all calls but never emits results.
///
/// Use this on platforms where real-time streaming inference is not
/// available (e.g. web, or when no model is loaded). Streams start
/// and stop cleanly, but [subscribeResults] returns an empty stream.
class LocalNoOpStreamInferenceAdapter implements StreamInferencePort {
  final Map<String, StreamController<StreamInferenceResult>> _streams = {};
  final Random _random;

  LocalNoOpStreamInferenceAdapter({Random? random})
      : _random = random ?? Random.secure();

  @override
  Future<String> startStream(StreamInferenceConfig config) async {
    final id = _generateId();
    _streams[id] = StreamController<StreamInferenceResult>.broadcast();
    _log.fine(
      'No-op stream $id started '
      '(source=${config.source}, mode=${config.mode.name})',
    );
    return id;
  }

  @override
  Future<void> updatePrompt(String streamId, String prompt) async {
    _log.fine('No-op updatePrompt on $streamId (ignored)');
  }

  @override
  Stream<StreamInferenceResult> subscribeResults(String streamId) {
    final controller = _streams[streamId];
    if (controller == null) return const Stream.empty();
    return controller.stream;
  }

  @override
  Future<void> stopStream(String streamId) async {
    final controller = _streams.remove(streamId);
    if (controller != null) {
      await controller.close();
      _log.fine('No-op stream $streamId stopped');
    }
  }

  @override
  Future<List<String>> activeStreams() async {
    return _streams.keys.toList();
  }

  String _generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final salt = _random.nextInt(1 << 16).toRadixString(16).padLeft(4, '0');
    return 'noop_${ts}_$salt';
  }
}
