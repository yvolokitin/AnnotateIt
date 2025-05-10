import 'package:flutter/material.dart';
import '../../../models/dataset_info.dart';

class StepDatasetOverview extends StatelessWidget {
  final DatasetInfo info;

  const StepDatasetOverview({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow("Dataset Path", info.datasetPath),
              _buildInfoRow("Dataset Type", info.datasetFormat),
              _buildInfoRow("Task Type", info.taskType),
              _buildInfoRow("Media Files", info.mediaCount.toString()),
              _buildInfoRow("Annotated Media Files", info.annotatedFilesCount.toString()),
              _buildInfoRow("Total Number Annotations", info.annotationCount.toString()),
              const SizedBox(height: 16),
              const Text(
                "Detected Labels",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              info.labels.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: info.labels
                          .map((label) => Chip(
                                label: Text(label,
                                    style: const TextStyle(color: Colors.black)),
                                backgroundColor: Colors.redAccent,
                              ))
                          .toList(),
                    )
                  : const Text("No labels detected.",
                      style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
