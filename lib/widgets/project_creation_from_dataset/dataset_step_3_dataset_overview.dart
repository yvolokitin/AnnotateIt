import 'package:flutter/material.dart';

import 'dataset_dialog_show_all_labels.dart';
import '../../../models/archive.dart';

class StepDatasetOverview extends StatelessWidget {
  final Archive archive;
  const StepDatasetOverview({super.key, required this.archive});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildCard(
                context,
                Icon(Icons.folder_copy_outlined, color: Colors.redAccent, size: 30),
                "Dataset name, path, type and format(s)",
                [
                  _buildRow(context, "ZIP Archive file name", archive.zipFileName),
                  _buildRow(context, "ZIP Archive Path", archive.datasetPath),
                  _buildRow(context, "Number of files in ZIP Archive", archive.mediaCount.toString()),
                  _buildRow(context, "Dataset Format", archive.datasetFormat),
                  _buildTaskTypesRow(context, archive.taskTypes),
                ],
              ),

              _buildCard(
                context,
                Icon(Icons.new_label_outlined, color: Colors.redAccent, size: 30),
                "Dataset Annotations and Labels",
                [
                  _buildRow(context, "Number of Annotated Files", archive.annotatedFilesCount.toString()),
                  _buildRow(context, "Number of Annotations", archive.annotationCount.toString()),
                  _buildLabelsCard(context, "Dataset Labels", archive.labels),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Icon icon, String title, List<Widget> rows) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 480,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.grey[850], // transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.redAccent.withOpacity(0.2),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      icon,
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'CascadiaCode',
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...rows,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTypesRow(BuildContext context, List<String> taskTypes) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dataset Task(s):",
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'CascadiaCode',
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: taskTypes
              .map((task) => Text(
                task,
                style: const TextStyle(
                  fontFamily: 'CascadiaCode',
                  fontSize: 16,
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelsCard(BuildContext context, String title, List<String> labels) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    int maxLabels = _getMaxLabelsForScreen(context);
    bool hasMore = labels.length > maxLabels;
    List<String> visibleLabels = labels.take(maxLabels).toList();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.redAccent.withOpacity(0.2),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flutter_dash, color: Colors.redAccent, size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'CascadiaCode',
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Total: ${labels.length}",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                  const SizedBox(height: 10),
                  visibleLabels.isNotEmpty
                      ? Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: visibleLabels
                              .map((label) => Chip(
                                    label: Text(
                                      label,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'CascadiaCode',
                                      ),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ))
                              .toList(),
                        )
                      : Text(
                        "No labels detected.",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                  if (hasMore) ...[
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _showAllLabelsDialog(context, labels),
                      label: Text(
                        "Show all labels",
                        style: TextStyle(
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAllLabelsDialog(BuildContext context, List<String> labels) {
    showDialog(
      context: context,
      builder: (context) => ShowAllLabelsDialog(labels: labels),
    );
  }

  int _getMaxLabelsForScreen(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1600) return 13; // desktop
    if (width >= 800) return 7; // tablet
    return 3; // small / mobile
  }

  Widget _buildRow(BuildContext context, String key, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$key: ",
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'CascadiaCode',
              color: colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'CascadiaCode',
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
