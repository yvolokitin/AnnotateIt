import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/services/stream_inference_port.dart';
import 'package:annotateit/services/local_noop_stream_inference_adapter.dart';
import 'package:annotateit/services/mock_stream_inference_adapter.dart';

void main() {
  // -----------------------------------------------------------------------
  // StreamOutputSchema
  // -----------------------------------------------------------------------

  group('StreamOutputSchema', () {
    test('toMap / fromMap roundtrip', () {
      const schema = StreamOutputSchema(
        name: 'bbox',
        fields: {'x': 'double', 'y': 'double', 'w': 'double', 'h': 'double'},
      );
      final restored = StreamOutputSchema.fromMap(schema.toMap());
      expect(restored.name, 'bbox');
      expect(restored.fields.length, 4);
    });
  });

  // -----------------------------------------------------------------------
  // StreamInferenceResult
  // -----------------------------------------------------------------------

  group('StreamInferenceResult', () {
    test('toString includes key fields', () {
      final r = StreamInferenceResult(
        streamId: 's1',
        sequenceNumber: 5,
        timestamp: DateTime.now(),
        payload: {'a': 1},
        latencyMs: 42,
      );
      expect(r.toString(), contains('s1'));
      expect(r.toString(), contains('seq=5'));
      expect(r.toString(), contains('42ms'));
    });
  });

  // -----------------------------------------------------------------------
  // LocalNoOpStreamInferenceAdapter
  // -----------------------------------------------------------------------

  group('LocalNoOpStreamInferenceAdapter', () {
    late LocalNoOpStreamInferenceAdapter adapter;

    setUp(() {
      adapter = LocalNoOpStreamInferenceAdapter(random: Random(42));
    });

    test('startStream returns a stream ID', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'camera_0',
        mode: StreamInferenceMode.detection,
      ));
      expect(id, startsWith('noop_'));
    });

    test('activeStreams tracks started streams', () async {
      expect(await adapter.activeStreams(), isEmpty);

      final id1 = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam', mode: StreamInferenceMode.ocr,
      ));
      final id2 = await adapter.startStream(const StreamInferenceConfig(
        source: 'file', mode: StreamInferenceMode.classification,
      ));

      final active = await adapter.activeStreams();
      expect(active, containsAll([id1, id2]));
    });

    test('subscribeResults returns empty stream that completes on stop', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.detection,
      ));

      final results = <StreamInferenceResult>[];
      final sub = adapter.subscribeResults(id).listen(results.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(results, isEmpty);

      await adapter.stopStream(id);
      await sub.cancel();
    });

    test('subscribeResults for unknown ID returns empty', () {
      final stream = adapter.subscribeResults('nonexistent');
      expectLater(stream, emitsDone);
    });

    test('stopStream removes from active', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.detection,
      ));
      await adapter.stopStream(id);
      expect(await adapter.activeStreams(), isEmpty);
    });

    test('stopStream on unknown ID is a no-op', () async {
      await adapter.stopStream('nonexistent');
    });

    test('updatePrompt does not throw', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.custom, prompt: 'initial',
      ));
      await adapter.updatePrompt(id, 'updated');
      await adapter.stopStream(id);
    });
  });

  // -----------------------------------------------------------------------
  // MockStreamInferenceAdapter
  // -----------------------------------------------------------------------

  group('MockStreamInferenceAdapter', () {
    late MockStreamInferenceAdapter adapter;

    setUp(() {
      adapter = MockStreamInferenceAdapter(
        emitInterval: const Duration(milliseconds: 30),
        random: Random(42),
      );
    });

    tearDown(() async {
      for (final id in await adapter.activeStreams()) {
        await adapter.stopStream(id);
      }
    });

    test('startStream returns a mock stream ID', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'video.mp4',
        mode: StreamInferenceMode.detection,
      ));
      expect(id, startsWith('mock_'));
    });

    test('subscribeResults emits detection payloads', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam', mode: StreamInferenceMode.detection,
      ));

      final results = <StreamInferenceResult>[];
      final sub = adapter.subscribeResults(id).listen(results.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await sub.cancel();
      await adapter.stopStream(id);

      expect(results, isNotEmpty);
      expect(results.first.streamId, id);
      expect(results.first.sequenceNumber, 1);
      expect(results.first.latencyMs, greaterThan(0));

      final payload = results.first.payload as Map<String, dynamic>;
      expect(payload, contains('detections'));
    });

    test('subscribeResults emits classification payloads', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam', mode: StreamInferenceMode.classification,
      ));

      final result = await adapter.subscribeResults(id).first;
      await adapter.stopStream(id);

      final payload = result.payload as Map<String, dynamic>;
      expect(payload, contains('labels'));
    });

    test('subscribeResults emits OCR payloads', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam', mode: StreamInferenceMode.ocr,
      ));

      final result = await adapter.subscribeResults(id).first;
      await adapter.stopStream(id);

      final payload = result.payload as Map<String, dynamic>;
      expect(payload['text'], contains('Sample text'));
    });

    test('subscribeResults emits segmentation payloads', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam', mode: StreamInferenceMode.segmentation,
      ));

      final result = await adapter.subscribeResults(id).first;
      await adapter.stopStream(id);

      final payload = result.payload as Map<String, dynamic>;
      expect(payload, contains('mask_width'));
      expect(payload['classes'], contains('person'));
    });

    test('subscribeResults emits custom payloads with prompt', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam',
        mode: StreamInferenceMode.custom,
        prompt: 'describe this',
      ));

      final result = await adapter.subscribeResults(id).first;
      await adapter.stopStream(id);

      final payload = result.payload as Map<String, dynamic>;
      expect(payload['prompt'], 'describe this');
      expect(payload['response'], contains('describe this'));
    });

    test('updatePrompt changes subsequent results', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam',
        mode: StreamInferenceMode.custom,
        prompt: 'original',
      ));

      await adapter.updatePrompt(id, 'updated prompt');

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final result = await adapter.subscribeResults(id).first;
      await adapter.stopStream(id);

      final payload = result.payload as Map<String, dynamic>;
      expect(payload['prompt'], 'updated prompt');
    });

    test('sequence numbers are monotonically increasing', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam', mode: StreamInferenceMode.detection,
      ));

      final results = await adapter
          .subscribeResults(id)
          .take(3)
          .toList();
      await adapter.stopStream(id);

      expect(results[0].sequenceNumber, 1);
      expect(results[1].sequenceNumber, 2);
      expect(results[2].sequenceNumber, 3);
    });

    test('stopStream completes the result stream', () async {
      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam', mode: StreamInferenceMode.detection,
      ));

      final stream = adapter.subscribeResults(id);
      await adapter.stopStream(id);

      expect(await adapter.activeStreams(), isEmpty);
      await expectLater(stream, emitsDone);
    });

    test('multiple concurrent streams are independent', () async {
      final id1 = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam1', mode: StreamInferenceMode.detection,
      ));
      final id2 = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam2', mode: StreamInferenceMode.classification,
      ));

      final r1 = await adapter.subscribeResults(id1).first;
      final r2 = await adapter.subscribeResults(id2).first;

      expect(r1.streamId, id1);
      expect(r2.streamId, id2);

      final p1 = r1.payload as Map<String, dynamic>;
      final p2 = r2.payload as Map<String, dynamic>;
      expect(p1, contains('detections'));
      expect(p2, contains('labels'));

      await adapter.stopStream(id1);
      await adapter.stopStream(id2);
    });

    test('subscribeResults for unknown ID returns empty', () {
      final stream = adapter.subscribeResults('nonexistent');
      expectLater(stream, emitsDone);
    });
  });

  // -----------------------------------------------------------------------
  // Polymorphism: both adapters satisfy the port contract
  // -----------------------------------------------------------------------

  group('StreamInferencePort polymorphism', () {
    final adapters = <String, StreamInferencePort>{
      'noop': LocalNoOpStreamInferenceAdapter(),
      'mock': MockStreamInferenceAdapter(
        emitInterval: const Duration(milliseconds: 20),
      ),
    };

    for (final entry in adapters.entries) {
      test('${entry.key} can start, subscribe, and stop', () async {
        final port = entry.value;
        final id = await port.startStream(const StreamInferenceConfig(
          source: 'test', mode: StreamInferenceMode.detection,
        ));

        expect(id, isNotEmpty);
        expect(await port.activeStreams(), contains(id));

        final sub = port.subscribeResults(id).listen((_) {});
        await port.updatePrompt(id, 'hello');
        await port.stopStream(id);
        await sub.cancel();

        expect(await port.activeStreams(), isNot(contains(id)));
      });
    }
  });
}
