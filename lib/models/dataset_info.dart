class DatasetInfo {
  final String datasetPath;
  final int mediaCount;
  final int annotationCount;
  final int annotatedFilesCount;
  final String datasetFormat;
  final String taskType;
  final List<String> labels;

  DatasetInfo({
    required this.datasetPath,
    required this.mediaCount,
    required this.annotationCount,
    required this.annotatedFilesCount,
    required this.datasetFormat,
    required this.taskType,
    required this.labels,
  });
}
