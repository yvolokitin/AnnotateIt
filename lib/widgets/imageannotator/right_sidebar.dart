import 'package:flutter/material.dart';
// import 'annotation_rect.dart'; // Removed
import '../../models/annotation.dart';
import '../../models/label.dart';

class RightSidebar extends StatelessWidget {
  final bool collapsed;
  // final List<AnnotationRect> annotations; // Old
  final List<Annotation> annotations;    // New
  final List<Label> labelDefinitions;
  final VoidCallback onToggleCollapse;
  final VoidCallback onSubmit;

  const RightSidebar({
    super.key,
    required this.collapsed,
    required this.annotations,
    required this.labelDefinitions, // Add this
    required this.onToggleCollapse,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 0 : 200,
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Annotations", style: TextStyle(color: Colors.white)),
              ),
              IconButton(
                icon: Icon(collapsed ? Icons.chevron_left : Icons.chevron_right, color: Colors.white),
                onPressed: onToggleCollapse,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: annotations.length,
              itemBuilder: (context, index) {
                final annotation = annotations[index];
                String labelName = 'No Label';

                if (annotation.labelId != null) {
                  try {
                    final label = labelDefinitions.firstWhere((l) => l.id == annotation.labelId);
                    labelName = label.name;
                  } catch (e) {
                    labelName = 'Unknown Label (ID: ${annotation.labelId})';
                  }
                } else if (annotation.labelId == null && annotation.annotationType.toLowerCase() == 'bbox') {
                  // This case might indicate a newly drawn bbox whose labelId wasn't set yet
                  // or an old annotation without a label.
                  labelName = "Unlabeled BBox";
                }

                String details = 'Type: ${annotation.annotationType}';
                if (annotation.annotationType.toLowerCase() == 'bbox' && annotation.data.isNotEmpty) {
                  final x = annotation.data['x'];
                  final y = annotation.data['y'];
                  final w = annotation.data['width'];
                  final h = annotation.data['height'];
                  details = 'x:${(x as num?)?.toStringAsFixed(0)}, y:${(y as num?)?.toStringAsFixed(0)}, w:${(w as num?)?.toStringAsFixed(0)}, h:${(h as num?)?.toStringAsFixed(0)}';
                }

                return ListTile(
                  title: Text(labelName, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(details, style: const TextStyle(color: Colors.white70)),
                  dense: true,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: onSubmit,
              child: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
