import 'package:flutter/material.dart';

class DatasetInfo {
  final String datasetPath;
  final int mediaCount;
  final int annotationCount;
  final String datasetFormat;
  final String taskType;
  final List<String> labels;

  DatasetInfo({
    required this.datasetPath,
    required this.mediaCount,
    required this.annotationCount,
    required this.datasetFormat,
    required this.taskType,
    required this.labels,
  });
}

class StepDatasetOverview extends StatelessWidget {
  final DatasetInfo info;
  const StepDatasetOverview({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenHeight + screenWidth) * 0.01; // scales with screen size

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dataset Overview",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24, thickness: 1),
                DefaultTextStyle(
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.folder, size: iconSize),
                          const SizedBox(width: 8),
                          const Text("Dataset Path:"),
                        ],
                      ),
                      SelectableText(
                        info.datasetPath,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.image, size: iconSize),
                          const SizedBox(width: 8),
                          const Text("Media & Annotations"),
                        ],
                      ),
                      Text("Media files: $info.mediaCount"),
                      Text("Annotation files: $info.annotationCount"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.insert_drive_file, size: iconSize),
                          const SizedBox(width: 8),
                          Text("Format: $info.datasetFormat"),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.analytics, size: iconSize),
                          const SizedBox(width: 8),
                          Text("Task Type: $info.taskType"),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.label, size: iconSize),
                          const SizedBox(width: 8),
                          Text("Labels $info.labels.length"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info.labels.join(', '),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
