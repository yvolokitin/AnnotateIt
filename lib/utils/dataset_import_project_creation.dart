import 'package:logging/logging.dart';

import '../models/dataset_info.dart';

class DatasetImportProjectCreation {
  static final Logger _logger = Logger('DatasetImportProjectCreation');

  /// Call this to create a project + default dataset in DB
  static Future<void> createProjectWithDataset(DatasetInfo datasetInfo) async {
    // TODO: Replace this with real DB logic.
    // Example: call your SQLite service or API backend
    final datasetPath = datasetInfo.datasetPath;
    final selectedTask = datasetInfo.selectedTaskType ?? 'Unknown';
    _logger.info('Creating project with dataset: $datasetPath and type: $selectedTask');

    // Simulate work for demo (remove in production)
    await Future.delayed(const Duration(seconds: 2));

    // Example: you could also add logic like:
    // await MyDatabaseService.instance.createProject(datasetInfo);
  }
}
