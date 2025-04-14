import 'package:flutter/material.dart';
import 'annotation_rect.dart';

class RightSidebar extends StatelessWidget {
  final bool collapsed;
  final List<AnnotationRect> annotations;
  final VoidCallback onToggleCollapse;
  final VoidCallback onSubmit;

  const RightSidebar({
    super.key,
    required this.collapsed,
    required this.annotations,
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
                return ListTile(
                  title: Text(annotation.label, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(annotation.rect.toString(), style: const TextStyle(color: Colors.white38)),
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
