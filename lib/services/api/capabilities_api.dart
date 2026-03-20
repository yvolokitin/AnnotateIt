import 'api_client.dart';

class CapabilitiesApi {
  final ApiClient _apiClient;

  const CapabilitiesApi({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<Map<String, dynamic>> fetchCapabilities() async {
    final response = await _apiClient.getJson('/capabilities');
    final body = response.body;
    if (body is Map<String, dynamic>) {
      return body;
    }
    throw const ApiClientException(
      message: 'Capabilities response must be a JSON object.',
      transient: false,
    );
  }
}
