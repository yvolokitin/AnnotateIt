import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:annotateit/services/api/api_client.dart';
import 'package:annotateit/services/api/capabilities_api.dart';

void main() {
  group('ApiClient', () {
    test('throws when base URL is empty', () {
      expect(
        () => ApiClient(baseUrl: ''),
        throwsA(isA<ApiClientConfigException>()),
      );
    });

    test('retries transient 5xx and succeeds', () async {
      var calls = 0;
      final mock = MockClient((_) async {
        calls += 1;
        if (calls == 1) {
          return http.Response('{"error":"temporary"}', 503);
        }
        return http.Response('{"ok":true}', 200);
      });

      final client = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mock,
        maxRetries: 2,
        baseRetryDelay: Duration.zero,
      );

      final response = await client.getJson('/health');
      expect(response.statusCode, 200);
      expect(response.body, <String, dynamic>{'ok': true});
      expect(calls, 2);
    });

    test('adds idempotency key on POST', () async {
      late http.Request captured;
      final mock = MockClient((request) async {
        captured = request;
        return http.Response('{"created":true}', 201);
      });

      final client = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mock,
      );

      await client.postJson(
        '/annotations',
        body: <String, dynamic>{'a': 1},
        idempotencyKey: 'abc-123',
      );

      expect(captured.headers['Idempotency-Key'], 'abc-123');
      expect(captured.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(captured.body), <String, dynamic>{'a': 1});
    });

    test('throws on non-JSON successful response', () async {
      final mock = MockClient((_) async => http.Response('not-json', 200));
      final client = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mock,
        maxRetries: 0,
      );

      await expectLater(
        client.getJson('/capabilities'),
        throwsA(isA<ApiClientException>()),
      );
    });
  });

  group('CapabilitiesApi', () {
    test('returns capabilities JSON object', () async {
      final mock = MockClient(
        (_) async => http.Response('{"ocr":true,"segmentation":false}', 200),
      );
      final client = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mock,
      );
      final api = CapabilitiesApi(apiClient: client);

      final capabilities = await api.fetchCapabilities();
      expect(capabilities['ocr'], true);
      expect(capabilities['segmentation'], false);
    });

    test('throws when capabilities payload is not an object', () async {
      final mock = MockClient((_) async => http.Response('[1,2,3]', 200));
      final client = ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mock,
      );
      final api = CapabilitiesApi(apiClient: client);

      await expectLater(
        api.fetchCapabilities(),
        throwsA(isA<ApiClientException>()),
      );
    });
  });
}
