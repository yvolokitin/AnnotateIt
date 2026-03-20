enum DeploymentMode { local, onprem, airgap }

class AppRuntimeConfig {
  static final AppRuntimeConfig instance = AppRuntimeConfig.fromEnvironment();

  final DeploymentMode deploymentMode;
  final String apiBaseUrl;
  final String modelRegistryBaseUrl;
  final bool allowExternalModelDownloads;

  const AppRuntimeConfig({
    required this.deploymentMode,
    required this.apiBaseUrl,
    required this.modelRegistryBaseUrl,
    required this.allowExternalModelDownloads,
  });

  factory AppRuntimeConfig.fromEnvironment() {
    final modeRaw = const String.fromEnvironment(
      'APP_DEPLOYMENT_MODE',
      defaultValue: 'local',
    );
    final apiBaseUrl =
        const String.fromEnvironment(
          'APP_API_BASE_URL',
          defaultValue: '',
        ).trim();
    final modelRegistryBaseUrl =
        const String.fromEnvironment(
          'APP_MODEL_REGISTRY_BASE_URL',
          defaultValue: '',
        ).trim();
    final allowExternalRaw =
        const String.fromEnvironment(
          'APP_ALLOW_EXTERNAL_MODEL_DOWNLOADS',
          defaultValue: '',
        ).trim();

    final deploymentMode = _parseMode(modeRaw);
    final allowExternalModelDownloads =
        allowExternalRaw.isEmpty
            ? deploymentMode != DeploymentMode.airgap
            : _parseBool(allowExternalRaw);

    return AppRuntimeConfig(
      deploymentMode: deploymentMode,
      apiBaseUrl: apiBaseUrl,
      modelRegistryBaseUrl: modelRegistryBaseUrl,
      allowExternalModelDownloads: allowExternalModelDownloads,
    );
  }

  List<String> validate() {
    final errors = <String>[];

    if (deploymentMode == DeploymentMode.airgap &&
        allowExternalModelDownloads) {
      errors.add(
        'APP_ALLOW_EXTERNAL_MODEL_DOWNLOADS must be false for APP_DEPLOYMENT_MODE=airgap.',
      );
    }

    if (deploymentMode == DeploymentMode.onprem && apiBaseUrl.isEmpty) {
      errors.add(
        'APP_API_BASE_URL is required for APP_DEPLOYMENT_MODE=onprem.',
      );
    }

    return errors;
  }

  String summary() {
    return 'mode=${deploymentMode.name}, '
        'apiBaseUrl=${apiBaseUrl.isEmpty ? '(empty)' : apiBaseUrl}, '
        'modelRegistryBaseUrl=${modelRegistryBaseUrl.isEmpty ? '(empty)' : modelRegistryBaseUrl}, '
        'allowExternalModelDownloads=$allowExternalModelDownloads';
  }

  static DeploymentMode _parseMode(String raw) {
    switch (raw.toLowerCase()) {
      case 'local':
        return DeploymentMode.local;
      case 'onprem':
        return DeploymentMode.onprem;
      case 'airgap':
        return DeploymentMode.airgap;
      default:
        return DeploymentMode.local;
    }
  }

  static bool _parseBool(String raw) {
    switch (raw.toLowerCase()) {
      case '1':
      case 'true':
      case 'yes':
        return true;
      case '0':
      case 'false':
      case 'no':
        return false;
      default:
        return false;
    }
  }
}
