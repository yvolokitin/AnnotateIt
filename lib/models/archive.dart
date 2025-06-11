class Archive {
  final String zipFileName;
  final String datasetPath;
  final int mediaCount;
  final int annotationCount;
  final int annotatedFilesCount;
  final String datasetFormat;
  final List<String> taskTypes;
  final String? selectedTaskType;
  final List<String> labels;

  Archive({
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

  Archive copyWith({
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
    return Archive(
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
      Archive(
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

  Archive withDefaultSelectedTaskType() {
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