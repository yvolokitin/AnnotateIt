// ✅ FINAL integrated version for inline StepDatasetTaskConfirmation + CreateFromDatasetDialog

// ---- StepDatasetTaskConfirmation.dart ----

import 'package:flutter/material.dart';
import '../../../models/dataset_info.dart';

class StepDatasetTaskConfirmation extends StatefulWidget {
  final DatasetInfo info;
  final void Function(String selectedTask) onConfirm;

  const StepDatasetTaskConfirmation({
    super.key,
    required this.info,
    required this.onConfirm,
  });

  @override
  State<StepDatasetTaskConfirmation> createState() => _StepDatasetTaskConfirmationState();
}

class _StepDatasetTaskConfirmationState extends State<StepDatasetTaskConfirmation> {
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

  @override
  void initState() {
    super.initState();
    selectedTask = widget.info.taskTypes.isNotEmpty
        ? widget.info.taskTypes.first
        : tasks.first['title'];
  }

  @override
  Widget build(BuildContext context) {
    final detectedTasks = widget.info.taskTypes.toSet();
    final isUnknown = detectedTasks.isEmpty || detectedTasks.contains("Unknown");

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Confirm Dataset Task",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: tasks.map((task) {
                final title = task['title']!;
                final enabled = isUnknown || detectedTasks.contains(title);
                final isSelected = selectedTask == title;

                return GestureDetector(
                  onTap: enabled
                      ? () => setState(() => selectedTask = title)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("This task is not detected. You can still select it, but annotations may be missing."),
                              backgroundColor: Colors.redAccent,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          setState(() => selectedTask = title);
                        },
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.redAccent
                          : enabled
                              ? Colors.grey[700]
                              : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.asset(
                            task['image']!,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: selectedTask != null ? () => widget.onConfirm(selectedTask!) : null,
              child: const Text("Confirm Selection", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
