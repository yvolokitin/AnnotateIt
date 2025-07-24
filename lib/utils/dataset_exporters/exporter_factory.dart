import '../../models/project.dart';

import 'base_dataset_exporter.dart';
import 'coco_exporter.dart';
import 'yolo_exporter.dart';
import 'datumaro_exporter.dart';

class ExporterFactory {
  static BaseDatasetExporter createExporter({
    required String datasetType,
    required Project project,
    required bool exportLabels,
    required bool exportAnnotations,
  }) {
    switch (datasetType.toUpperCase()) {
      case 'COCO':
        return COCOExporter(
          project: project,
          exportLabels: exportLabels,
          exportAnnotations: exportAnnotations,
        );
      case 'YOLO':
        return YOLOExporter(
          project: project,
          exportLabels: exportLabels,
          exportAnnotations: exportAnnotations,
        );
      case 'DATUMARO':
        return DatumaroExporter(
          project: project,
          exportLabels: exportLabels,
          exportAnnotations: exportAnnotations,
        );
      default:
        throw ArgumentError('Unsupported dataset type: $datasetType');
    }
  }
}
