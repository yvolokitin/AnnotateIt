// lib/models/dataset_info.dart

class DatasetInfo {
  /// Name of the original dataset ZIP file
  final String zipFileName;

  /// Local path where the dataset was extracted
  final String datasetPath;

  /// Total number of media files (images/videos)
  final int mediaCount;

  /// Total number of annotation items
  final int annotationCount;

  /// Number of media files that have at least one annotation
  final int annotatedFilesCount;

  /// Detected dataset format (COCO, YOLO, VOC, etc.)
  final String datasetFormat;

  /// Detected possible dataset task types (Detection, Classification etc.)
  final List<String> taskTypes;

  /// User-selected task type for project creation
  final String? selectedTaskType;

  /// List of detected label names
  final List<String> labels;

  DatasetInfo({
    required this.zipFileName,
    required this.datasetPath,
    required this.mediaCount,
    required this.annotationCount,
    required this.annotatedFilesCount,
    required this.datasetFormat,
    required this.taskTypes,
    this.selectedTaskType,
    required this.labels,
  });

  /// Creates a copy of this object with optional new values
  DatasetInfo copyWith({
    String? zipFileName,
    String? datasetPath,
    int? mediaCount,
    int? annotationCount,
    int? annotatedFilesCount,
    String? datasetFormat,
    List<String>? taskTypes,
    String? selectedTaskType,
    List<String>? labels,
  }) {
    return DatasetInfo(
      zipFileName: zipFileName ?? this.zipFileName,
      datasetPath: datasetPath ?? this.datasetPath,
      mediaCount: mediaCount ?? this.mediaCount,
      annotationCount: annotationCount ?? this.annotationCount,
      annotatedFilesCount: annotatedFilesCount ?? this.annotatedFilesCount,
      datasetFormat: datasetFormat ?? this.datasetFormat,
      taskTypes: taskTypes ?? this.taskTypes,
      selectedTaskType: selectedTaskType ?? this.selectedTaskType,
      labels: labels ?? this.labels,
    );
  }

  @override
  String toString() {
    return '''
      DatasetInfo(
      zipFileName: $zipFileName,
      datasetPath: $datasetPath,
      mediaCount: $mediaCount,
      annotationCount: $annotationCount,
      annotatedFilesCount: $annotatedFilesCount,
      datasetFormat: $datasetFormat,
      taskTypes: ${taskTypes.join(', ')},
      selectedTaskType: $selectedTaskType,
      labels: ${labels.length} labels
    )
    ''';
  }

  DatasetInfo withDefaultSelectedTaskType() {
    if ((selectedTaskType != null && selectedTaskType!.isNotEmpty) || taskTypes.isEmpty) {
      // already assigned or no detected types
      return this;
    }

    final defaultType = (taskTypes.first == "Unknown")
      ? "Detection bounding box"
      : taskTypes.first;

    return copyWith(selectedTaskType: defaultType);
  }
}
