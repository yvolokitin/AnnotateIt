import 'package:flutter/material.dart';

class StepProjectTypeSelection extends StatefulWidget {
  final String projectType;
  final void Function(String selectedTask)? onSelectionChanged;

  const StepProjectTypeSelection({
    super.key,
    required this.projectType,
    required this.onSelectionChanged,
  });

  @override
  State<StepProjectTypeSelection> createState() =>
      StepProjectTypeSelectionState();
}

class StepProjectTypeSelectionState extends State<StepProjectTypeSelection> {
  static const tasks = [
    {'title': 'Detection bounding box', 'image': 'assets/images/detection_bounding_box.jpg'},
    {'title': 'Detection oriented', 'image': 'assets/images/detection_oriented.jpg'},
    {'title': 'Binary Classification', 'image': 'assets/images/classification_binary.jpg'},
    {'title': 'Multi-class Classification', 'image': 'assets/images/classification_multi_class.jpg'},
    {'title': 'Multi-label Classification', 'image': 'assets/images/anomaly_detection.jpg'},
    {'title': 'Instance Segmentation', 'image': 'assets/images/instance_segmentation.jpg'},
    {'title': 'Semantic Segmentation', 'image': 'assets/images/semantic_segmentation.jpg'},
  ];

  String? selectedTask;

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((task) => task['title'] != widget.projectType).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    children: filteredTasks.map((task) {
                      final title = task['title']!;
                      final isSelected = selectedTask == title;

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTask = title;
                            });
                            widget.onSelectionChanged?.call(title);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: cardSize,
                            height: cardSize,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: Colors.redAccent, width: 3)
                                  : null,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
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
                                            fontFamily: 'CascadiaCode',
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

  String? getSelectedTask() => selectedTask;
}
