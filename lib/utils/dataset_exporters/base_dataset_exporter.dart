import 'package:logging/logging.dart';
import 'package:archive/archive.dart';

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';

abstract class BaseDatasetExporter {
  static final Logger _logger = Logger('BaseDatasetExporter');

  final Project project;
  final bool exportLabels;
  final bool exportAnnotations;

  BaseDatasetExporter({
    required this.project,
    required this.exportLabels,
    required this.exportAnnotations,
  });

  /// Собирает архив (ZIP) из переданных данных проекта
  Future<Archive> buildArchive({
    required List<Label> labels,
    required List<MediaItem> mediaItems,
    required Map<int, List<Annotation>> annotationsByMediaId,
  });
}
