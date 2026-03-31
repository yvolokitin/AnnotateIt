import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/models/ai_result_envelope.dart';
import 'package:annotateit/services/api_key_provider.dart';
import 'package:annotateit/services/external_stream_adapter.dart';
import 'package:annotateit/services/stream_inference_port.dart';

void main() {
  // -----------------------------------------------------------------------
  // ApiKeyProvider
  // -----------------------------------------------------------------------

  group('InMemoryApiKeyProvider', () {
    test('returns null when no key set', () async {
      final provider = InMemoryApiKeyProvider();
      expect(await provider.getApiKey('test'), isNull);
      expect(await provider.hasApiKey('test'), false);
    });

    test('returns key after setKey', () async {
      final provider = InMemoryApiKeyProvider();
      provider.setKey('svc', 'sk-123');
      expect(await provider.getApiKey('svc'), 'sk-123');
      expect(await provider.hasApiKey('svc'), true);
    });

    test('removeKey clears the key', () async {
      final provider = InMemoryApiKeyProvider();
      provider.setKey('svc', 'sk-123');
      provider.removeKey('svc');
      expect(await provider.getApiKey('svc'), isNull);
    });

    test('clear removes all keys', () async {
      final provider = InMemoryApiKeyProvider();
      provider.setKey('a', '1');
      provider.setKey('b', '2');
      provider.clear();
      expect(await provider.hasApiKey('a'), false);
      expect(await provider.hasApiKey('b'), false);
    });
  });

  // -----------------------------------------------------------------------
  // MissingApiKeyException
  // -----------------------------------------------------------------------

  group('MissingApiKeyException', () {
    test('toString includes service name', () {
      const e = MissingApiKeyException('vision_api');
      expect(e.toString(), contains('vision_api'));
      expect(e.toString(), contains('VISION_API_API_KEY'));
    });
  });

  // -----------------------------------------------------------------------
  // ExternalStreamAdapter — degradation
  // -----------------------------------------------------------------------

  group('ExternalStreamAdapter degradation', () {
    test('startStream throws MissingApiKeyException when no key', () async {
      final provider = InMemoryApiKeyProvider();
      final adapter = ExternalStreamAdapter(
        keyProvider: provider,
        serviceName: 'test_svc',
      );

      expect(
        () => adapter.startStream(const StreamInferenceConfig(
          source: 'cam', mode: StreamInferenceMode.detection,
        )),
        throwsA(isA<MissingApiKeyException>()),
      );
    });

    test('activeStreams returns empty when no key', () async {
      final provider = InMemoryApiKeyProvider();
      final adapter = ExternalStreamAdapter(keyProvider: provider);
      expect(await adapter.activeStreams(), isEmpty);
    });

    test('subscribeResults returns empty for unknown ID', () {
      final provider = InMemoryApiKeyProvider();
      final adapter = ExternalStreamAdapter(keyProvider: provider);
      final stream = adapter.subscribeResults('nonexistent');
      expectLater(stream, emitsDone);
    });

    test('stopStream on unknown ID is a no-op', () async {
      final provider = InMemoryApiKeyProvider();
      final adapter = ExternalStreamAdapter(keyProvider: provider);
      await adapter.stopStream('nonexistent');
    });
  });

  // -----------------------------------------------------------------------
  // ExternalStreamAdapter — with mock HTTP
  // -----------------------------------------------------------------------

  group('ExternalStreamAdapter with mock HTTP', () {
    late InMemoryApiKeyProvider keyProvider;
    late List<_HttpCall> httpCalls;

    setUp(() {
      keyProvider = InMemoryApiKeyProvider();
      keyProvider.setKey('test_svc', 'sk-test-key');
      httpCalls = [];
    });

    ExternalStreamAdapter createAdapter({
      Map<String, dynamic> Function(String url)? responseBuilder,
      Duration pollInterval = const Duration(milliseconds: 30),
    }) {
      return ExternalStreamAdapter(
        keyProvider: keyProvider,
        serviceName: 'test_svc',
        baseUrl: 'https://mock.api/v1/inference',
        pollInterval: pollInterval,
        keepAliveInterval: const Duration(seconds: 60),
        random: Random(42),
        httpPost: (url, headers, body) async {
          httpCalls.add(_HttpCall(url: url, headers: headers, body: body));

          if (responseBuilder != null) return responseBuilder(url);

          if (url.contains('/streams') && !url.contains('/')) {
            return {'stream_id': 'remote-123'};
          }
          if (url.endsWith('/results')) {
            return {
              'model': 'test-model',
              'version': '1.0',
              'status': 'success',
              'latency_ms': 25,
              'result': {'label': 'cat', 'confidence': 0.95},
            };
          }
          return {'ok': true};
        },
      );
    }

    test('startStream calls external API with auth header', () async {
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) {
            return {'stream_id': 'remote-abc'};
          }
          return {
            'model': 'm', 'version': 'v', 'status': 'success',
            'result': {}, 'latency_ms': 10,
          };
        },
      );

      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam0',
        mode: StreamInferenceMode.detection,
        prompt: 'find objects',
      ));

      expect(id, startsWith('ext_'));
      expect(httpCalls.first.url, 'https://mock.api/v1/inference/streams');
      expect(httpCalls.first.headers['Authorization'], 'Bearer sk-test-key');
      expect(httpCalls.first.body['source'], 'cam0');
      expect(httpCalls.first.body['mode'], 'detection');
      expect(httpCalls.first.body['prompt'], 'find objects');

      await adapter.stopStream(id);
    });

    test('subscribeResults emits results from external API', () async {
      int callCount = 0;
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) {
            return {'stream_id': 'remote-1'};
          }
          if (url.endsWith('/results')) {
            callCount++;
            return {
              'model': 'ext-det',
              'version': '2.0',
              'status': 'success',
              'latency_ms': 15,
              'result': {'label': 'dog_$callCount', 'confidence': 0.9},
            };
          }
          return {'ok': true};
        },
      );

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
      expect(results.first.latencyMs, greaterThanOrEqualTo(0));

      final payload = results.first.payload as Map<String, dynamic>;
      expect(payload['label'], startsWith('dog_'));
      expect(payload['_envelope'], isNotNull);
    });

    test('results contain unified envelope metadata', () async {
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) return {'stream_id': 'r1'};
          if (url.endsWith('/results')) {
            return {
              'model': 'cloud-vision',
              'version': '3.1',
              'status': 'success',
              'latency_ms': 33,
              'result': {'text': 'hello'},
            };
          }
          return {};
        },
      );

      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.ocr,
      ));

      final result = await adapter.subscribeResults(id).first;
      await adapter.stopStream(id);

      final envelope = result.payload['_envelope'] as Map<String, dynamic>;
      expect(envelope['modelName'], 'cloud-vision');
      expect(envelope['modelVersion'], '3.1');
      expect(envelope['backendType'], 'external');
      expect(envelope['finishReason'], 'success');
    });

    test('updatePrompt sends to external API', () async {
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) return {'stream_id': 'r-p'};
          return {'model': 'm', 'version': 'v', 'status': 'success',
            'result': {}, 'latency_ms': 1};
        },
      );

      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.custom, prompt: 'v1',
      ));

      await adapter.updatePrompt(id, 'v2');

      final promptCall = httpCalls.where(
        (c) => c.url.endsWith('/prompt'),
      );
      expect(promptCall, isNotEmpty);
      expect(promptCall.first.body['prompt'], 'v2');

      await adapter.stopStream(id);
    });

    test('stopStream calls stop on remote', () async {
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) return {'stream_id': 'r-stop'};
          return {'model': 'm', 'version': 'v', 'status': 'success',
            'result': {}, 'latency_ms': 1};
        },
      );

      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.detection,
      ));
      await adapter.stopStream(id);

      final stopCalls = httpCalls.where((c) => c.url.endsWith('/stop'));
      expect(stopCalls, isNotEmpty);
      expect(await adapter.activeStreams(), isEmpty);
    });

    test('error response maps to error envelope', () async {
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) return {'stream_id': 'r-err'};
          if (url.endsWith('/results')) {
            return {
              'model': 'fail-model',
              'version': '1.0',
              'status': 'error',
              'error': 'GPU out of memory',
            };
          }
          return {};
        },
      );

      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.detection,
      ));

      final result = await adapter.subscribeResults(id).first;
      await adapter.stopStream(id);

      final envelope = result.payload['_envelope'] as Map<String, dynamic>;
      expect(envelope['finishReason'], 'error');
      expect(envelope['errorMessage'], 'GPU out of memory');
    });

    test('empty response maps to empty envelope', () async {
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) return {'stream_id': 'r-empty'};
          if (url.endsWith('/results')) {
            return {
              'model': 'empty-model',
              'version': '1.0',
              'status': 'empty',
            };
          }
          return {};
        },
      );

      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.detection,
      ));

      final result = await adapter.subscribeResults(id).first;
      await adapter.stopStream(id);

      final envelope = result.payload['_envelope'] as Map<String, dynamic>;
      expect(envelope['finishReason'], 'empty');
    });

    test('HTTP failure in create stream propagates', () async {
      keyProvider.setKey('test_svc', 'sk-valid');
      final adapter = ExternalStreamAdapter(
        keyProvider: keyProvider,
        serviceName: 'test_svc',
        httpPost: (url, headers, body) async {
          throw Exception('Connection refused');
        },
      );

      expect(
        () => adapter.startStream(const StreamInferenceConfig(
          source: 's', mode: StreamInferenceMode.detection,
        )),
        throwsA(isA<Exception>()),
      );
    });

    test('poll errors do not kill the stream', () async {
      int pollCount = 0;
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) return {'stream_id': 'r-resilient'};
          if (url.endsWith('/results')) {
            pollCount++;
            if (pollCount == 1) throw Exception('transient error');
            return {
              'model': 'm', 'version': 'v', 'status': 'success',
              'result': {'ok': true}, 'latency_ms': 5,
            };
          }
          return {};
        },
      );

      final id = await adapter.startStream(const StreamInferenceConfig(
        source: 's', mode: StreamInferenceMode.detection,
      ));

      final results = <StreamInferenceResult>[];
      final sub = adapter.subscribeResults(id).listen(results.add);

      await Future<void>.delayed(const Duration(milliseconds: 120));
      await sub.cancel();
      await adapter.stopStream(id);

      expect(results, isNotEmpty);
    });

    test('multiple concurrent streams are independent', () async {
      final adapter = createAdapter(
        responseBuilder: (url) {
          if (url.endsWith('/streams')) {
            return {'stream_id': 'r-${DateTime.now().microsecondsSinceEpoch}'};
          }
          return {
            'model': 'm', 'version': 'v', 'status': 'success',
            'result': {'data': 1}, 'latency_ms': 5,
          };
        },
      );

      final id1 = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam1', mode: StreamInferenceMode.detection,
      ));
      final id2 = await adapter.startStream(const StreamInferenceConfig(
        source: 'cam2', mode: StreamInferenceMode.classification,
      ));

      expect(id1, isNot(equals(id2)));
      final active = await adapter.activeStreams();
      expect(active, containsAll([id1, id2]));

      await adapter.stopStream(id1);
      await adapter.stopStream(id2);
    });
  });

  // -----------------------------------------------------------------------
  // mapResponseToEnvelope
  // -----------------------------------------------------------------------

  group('mapResponseToEnvelope', () {
    late ExternalStreamAdapter adapter;

    setUp(() {
      adapter = ExternalStreamAdapter(
        keyProvider: InMemoryApiKeyProvider(),
        serviceName: 'test',
      );
    });

    test('success response', () {
      final envelope = adapter.mapResponseToEnvelope({
        'model': 'yolo-v8',
        'version': '8.0.1',
        'status': 'success',
        'latency_ms': 42,
        'result': {'boxes': [1, 2, 3]},
      });

      expect(envelope.isSuccess, true);
      expect(envelope.modelName, 'yolo-v8');
      expect(envelope.backendType, AiBackendType.external);
      expect(envelope.inferenceLatencyMs, 42);
      expect(envelope.payload!['boxes'], [1, 2, 3]);
    });

    test('error response', () {
      final envelope = adapter.mapResponseToEnvelope({
        'model': 'x',
        'version': '1',
        'status': 'error',
        'error': 'timeout',
      });

      expect(envelope.finishReason, AiFinishReason.error);
      expect(envelope.errorMessage, 'timeout');
    });

    test('empty response', () {
      final envelope = adapter.mapResponseToEnvelope({
        'model': 'x',
        'version': '1',
        'status': 'empty',
      });

      expect(envelope.finishReason, AiFinishReason.empty);
      expect(envelope.hasPayload, false);
    });

    test('missing fields use defaults', () {
      final envelope = adapter.mapResponseToEnvelope({});
      expect(envelope.modelName, 'test');
      expect(envelope.modelVersion, 'unknown');
      expect(envelope.isSuccess, true);
    });
  });
}

class _HttpCall {
  final String url;
  final Map<String, String> headers;
  final Map<String, dynamic> body;

  const _HttpCall({
    required this.url,
    required this.headers,
    required this.body,
  });
}
