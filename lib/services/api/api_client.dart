import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_runtime_config.dart';

class ApiClientConfigException implements Exception {
  final String message;

  const ApiClientConfigException(this.message);

  @override
  String toString() => 'ApiClientConfigException: $message';
}

class ApiClientException implements Exception {
  final String message;
  final int? statusCode;
  final Uri? uri;
  final bool transient;
  final Object? cause;

  const ApiClientException({
    required this.message,
    this.statusCode,
    this.uri,
    this.transient = false,
    this.cause,
  });

  @override
  String toString() =>
      'ApiClientException(message: $message, statusCode: $statusCode, uri: $uri, transient: $transient, cause: $cause)';
}

class ApiResponse {
  final int statusCode;
  final Map<String, String> headers;
  final dynamic body;

  const ApiResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class ApiClient {
  final Uri _baseUri;
  final http.Client _httpClient;
  final Duration _requestTimeout;
  final int _maxRetries;
  final Duration _baseRetryDelay;

  ApiClient({
    required String baseUrl,
    http.Client? httpClient,
    Duration requestTimeout = const Duration(seconds: 20),
    int maxRetries = 2,
    Duration baseRetryDelay = const Duration(milliseconds: 300),
  }) : _baseUri = _parseAndValidateBaseUrl(baseUrl),
       _httpClient = httpClient ?? http.Client(),
       _requestTimeout = requestTimeout,
       _maxRetries = maxRetries,
       _baseRetryDelay = baseRetryDelay;

  factory ApiClient.fromRuntimeConfig({
    AppRuntimeConfig? config,
    http.Client? httpClient,
  }) {
    final cfg = config ?? AppRuntimeConfig.instance;
    return ApiClient(baseUrl: cfg.apiBaseUrl, httpClient: httpClient);
  }

  static Uri _parseAndValidateBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) {
      throw const ApiClientConfigException(
        'API base URL is empty. Set APP_API_BASE_URL for on-prem/backend-connected mode.',
      );
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw ApiClientConfigException(
        'Invalid API base URL: "$baseUrl". Expected absolute URL such as https://api.example.com.',
      );
    }
    return uri;
  }

  Future<ApiResponse> getJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'GET',
      uri: _resolve(path),
      headers: _buildHeaders(headers: headers),
    );
  }

  Future<ApiResponse> postJson(
    String path, {
    Object? body,
    String? idempotencyKey,
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'POST',
      uri: _resolve(path),
      headers: _buildHeaders(
        headers: headers,
        idempotencyKey: idempotencyKey,
        includeJsonContentType: body != null,
      ),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<ApiResponse> patchJson(
    String path, {
    Object? body,
    String? idempotencyKey,
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'PATCH',
      uri: _resolve(path),
      headers: _buildHeaders(
        headers: headers,
        idempotencyKey: idempotencyKey,
        includeJsonContentType: body != null,
      ),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Uri _resolve(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return _baseUri.resolve(normalized);
  }

  Map<String, String> _buildHeaders({
    Map<String, String>? headers,
    String? idempotencyKey,
    bool includeJsonContentType = false,
  }) {
    final built = <String, String>{'Accept': 'application/json', ...?headers};
    if (idempotencyKey != null && idempotencyKey.trim().isNotEmpty) {
      built['Idempotency-Key'] = idempotencyKey.trim();
    }
    if (includeJsonContentType) {
      built['Content-Type'] = 'application/json';
    }
    return built;
  }

  Future<ApiResponse> _send({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    String? body,
  }) async {
    Object? lastError;
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final request = http.Request(method, uri);
        if (headers != null) {
          request.headers.addAll(headers);
        }
        if (body != null) {
          request.body = body;
        }

        final streamed = await _httpClient
            .send(request)
            .timeout(_requestTimeout);
        final response = await http.Response.fromStream(streamed);

        if (_shouldRetryStatus(response.statusCode) && attempt < _maxRetries) {
          await _backoff(attempt);
          continue;
        }

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw ApiClientException(
            message: 'HTTP ${response.statusCode}: ${response.body}',
            statusCode: response.statusCode,
            uri: uri,
            transient: _shouldRetryStatus(response.statusCode),
          );
        }

        final parsedBody = _parseJsonBody(response);
        return ApiResponse(
          statusCode: response.statusCode,
          headers: response.headers,
          body: parsedBody,
        );
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt >= _maxRetries) {
          throw ApiClientException(
            message: 'Request timeout',
            uri: uri,
            transient: true,
            cause: e,
          );
        }
        await _backoff(attempt);
      } on ApiClientException {
        rethrow;
      } catch (e) {
        lastError = e;
        if (attempt >= _maxRetries) {
          throw ApiClientException(
            message: 'Request failed: $e',
            uri: uri,
            transient: true,
            cause: e,
          );
        }
        await _backoff(attempt);
      }
    }

    throw ApiClientException(
      message: 'Request failed after retries',
      uri: uri,
      transient: true,
      cause: lastError,
    );
  }

  dynamic _parseJsonBody(http.Response response) {
    if (response.body.isEmpty) {
      return const <String, dynamic>{};
    }
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw ApiClientException(
        message: 'Expected JSON response but failed to decode payload',
        statusCode: response.statusCode,
        transient: false,
        cause: e,
      );
    }
  }

  bool _shouldRetryStatus(int statusCode) {
    return statusCode == 429 || (statusCode >= 500 && statusCode <= 599);
  }

  Future<void> _backoff(int attempt) async {
    final delayMs =
        _baseRetryDelay.inMilliseconds * (attempt + 1) * (attempt + 1);
    await Future<void>.delayed(Duration(milliseconds: delayMs));
  }

  void close() {
    _httpClient.close();
  }
}
