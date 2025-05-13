import 'package:flutter/material.dart';
import '../../../models/dataset_info.dart';

class StepDatasetTaskConfirmation extends StatefulWidget {
  final DatasetInfo info;
  final void Function(String selectedTask)? onSelectionChanged;

  const StepDatasetTaskConfirmation({
    super.key,
    required this.info,
    this.onSelectionChanged,
  });

  @override
  State<StepDatasetTaskConfirmation> createState() =>
      StepDatasetTaskConfirmationState();
}

class StepDatasetTaskConfirmationState
    extends State<StepDatasetTaskConfirmation> {
  static const tasks = [
    {'title': 'Detection bounding box', 'image': 'assets/images/detection_bounding_box.jpg'},
    {'title': 'Detection oriented', 'image': 'assets/images/detection_oriented.jpg'},
    {'title': 'Anomaly detection', 'image': 'assets/images/anomaly_detection.jpg'},
    {'title': 'Binary Classification', 'image': 'assets/images/classification_binary.jpg'},
    {'title': 'Multi-class Classification', 'image': 'assets/images/classification_multi_class.jpg'},
    {'title': 'Multi-label Classification', 'image': 'assets/images/anomaly_detection.jpg'},
    {'title': 'Hierarchical Classification', 'image': 'assets/images/anomaly_detection.jpg'},
    {'title': 'Instance Segmentation', 'image': 'assets/images/instance_segmentation.jpg'},
    {'title': 'Semantic Segmentation', 'image': 'assets/images/semantic_segmentation.jpg'},
  ];

  late String? selectedTask;
  bool ignoreDisabled = false;

  @override
  void initState() {
    super.initState();
    selectedTask = widget.info.taskTypes.isNotEmpty
        ? widget.info.taskTypes.first
        : tasks.first['title'];
  }

  /// ✅ Parent can retrieve current selection
  String? getSelectedTask() => selectedTask;

  @override
  Widget build(BuildContext context) {
    final detectedTasks = widget.info.taskTypes.toSet();
    final allEnabled = detectedTasks.contains("Unknown") || detectedTasks.isEmpty;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  "Confirm Dataset Task",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text("Ignore disabled", style: TextStyle(color: Colors.white70)),
                    Switch(
                      value: ignoreDisabled,
                      onChanged: (value) {
                        setState(() {
                          ignoreDisabled = value;
                        });
                      },
                      activeColor: Colors.redAccent, // ✅ Red switch
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const double minCardSize = 100;
                const double maxCardSize = 250;
                const double spacing = 16;

                double availableWidth = constraints.maxWidth;
                double rawCardSize = (availableWidth - spacing * 2) / 3;
                double cardSize = rawCardSize.clamp(minCardSize, maxCardSize);

                return Center(
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: tasks.map((task) {
                      final title = task['title']!;
                      final isDetected = allEnabled || detectedTasks.contains(title);
                      final enabled = ignoreDisabled || isDetected;
                      final isSelected = selectedTask == title;

                      return MouseRegion(
                        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: enabled
                              ? () => setState(() {
                                  selectedTask = title;
                                  widget.onSelectionChanged?.call(title);  // ✅ Call parent callback
                                })
                              : null,
                          child: Opacity(
                            opacity: enabled ? 1.0 : 0.4,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: cardSize,
                              height: cardSize,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: Colors.redAccent, width: 3) // ✅ Red border
                                    : null,
                                boxShadow: enabled
                                    ? [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.asset(
                                      task['image']!,
                                      height: cardSize * 0.7,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            title,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
