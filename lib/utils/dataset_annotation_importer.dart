import 'package:logging/logging.dart';

import '../models/media_item.dart';
import '../models/label.dart';
import '../data/annotation_database.dart';

import 'dataset_annotation_parsers/coco_parser.dart';
import 'dataset_annotation_parsers/yolo_parser.dart';
import 'dataset_annotation_parsers/voc_parser.dart';
import 'dataset_annotation_parsers/datumaro_parser.dart';
import 'dataset_annotation_parsers/labelme_parser.dart';
import 'dataset_annotation_parsers/cvat_parser.dart';

class DatasetAnnotationImporter {
  final AnnotationDatabase annotationDb;
  
  final Logger _logger = Logger('DatasetAnnotationImporter');

  DatasetAnnotationImporter({required this.annotationDb});

  Future<int> addAnnotationsToProjectFromDataset({
    required String projectType,
    required List<Label> projectLabels,
    required String datasetPath,
    required String format,
    required Map<String, MediaItem> mediaItemsMap,
    required int projectId,
    required int annotatorId,
    bool convertPolygonsToBbox = false,
  }) async {
    switch (format.toLowerCase()) {
      case 'coco':
        return await COCOParser.parse(
          projectType: projectType,
          projectLabels: projectLabels,
          datasetPath: datasetPath,
          mediaItemsMap: mediaItemsMap,
          annotationDb: annotationDb,
          projectId: projectId,
          annotatorId: annotatorId,
        );

      case 'datumaro':
        return await DatumaroParser.parse(
          projectType: projectType,
          projectLabels: projectLabels,
          datasetPath: datasetPath,
          mediaItemsMap: mediaItemsMap,
          annotationDb: annotationDb,
          projectId: projectId,
          annotatorId: annotatorId,
          convertPolygonsToBbox: convertPolygonsToBbox,
        );

      case 'yolo':
        return await YOLOParser.parse(
          projectType: projectType,
          projectLabels: projectLabels,
          datasetPath: datasetPath,
          mediaItemsMap: mediaItemsMap,
          annotationDb: annotationDb,
          projectId: projectId,
          annotatorId: annotatorId,
        );

      case 'voc':
        return await VOCParser.parse(
          projectType: projectType,
          projectLabels: projectLabels,
          datasetPath: datasetPath,
          mediaItemsMap: mediaItemsMap,
          annotationDb: annotationDb,
          projectId: projectId,
          annotatorId: annotatorId,
        );

      case 'labelme':
        return await LabelMeParser.parse(
          projectType: projectType,
          projectLabels: projectLabels,
          datasetPath: datasetPath,
          mediaItemsMap: mediaItemsMap,
          annotationDb: annotationDb,
          projectId: projectId,
          annotatorId: annotatorId,
        );

      case 'cvat':
        return await CVATParser.parse(
          projectType: projectType,
          projectLabels: projectLabels,
          datasetPath: datasetPath,
          mediaItemsMap: mediaItemsMap,
          annotationDb: annotationDb,
          projectId: projectId,
          annotatorId: annotatorId,
        );

      default:
        _logger.warning('[Importer] Dataset format "$format" not supported. Skipping.');
        return 0;
    }
  }
}