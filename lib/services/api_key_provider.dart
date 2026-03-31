import 'dart:io';

import 'package:logging/logging.dart';

final _log = Logger('ApiKeyProvider');

/// Abstraction for retrieving API keys without coupling to a specific
/// storage backend. Implementations can read from environment variables,
/// secure storage, a config file, etc.
abstract class ApiKeyProvider {
  /// Returns the API key for the given [service], or `null` if unavailable.
  Future<String?> getApiKey(String service);

  /// Returns `true` if a key is configured for [service].
  Future<bool> hasApiKey(String service) async {
    final key = await getApiKey(service);
    return key != null && key.isNotEmpty;
  }
}

/// Reads API keys from environment variables.
///
/// Convention: key for service `"foo"` is read from env var
/// `FOO_API_KEY` (uppercased service name + `_API_KEY`).
class EnvApiKeyProvider extends ApiKeyProvider {
  final Map<String, String>? _overrides;

  /// [overrides] can inject keys for testing without touching the real env.
  EnvApiKeyProvider({Map<String, String>? overrides}) : _overrides = overrides;

  @override
  Future<String?> getApiKey(String service) async {
    final envName = '${service.toUpperCase()}_API_KEY';

    if (_overrides != null && _overrides.containsKey(envName)) {
      return _overrides[envName];
    }

    final value = Platform.environment[envName];
    if (value == null || value.isEmpty) {
      _log.fine('No API key found for "$service" (env: $envName)');
      return null;
    }
    return value;
  }
}

/// In-memory provider for testing — keys are set programmatically.
class InMemoryApiKeyProvider extends ApiKeyProvider {
  final Map<String, String> _keys = {};

  void setKey(String service, String key) => _keys[service] = key;
  void removeKey(String service) => _keys.remove(service);
  void clear() => _keys.clear();

  @override
  Future<String?> getApiKey(String service) async => _keys[service];
}
