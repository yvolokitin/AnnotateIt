import 'package:flutter/material.dart';

class LabelEditorWidget extends StatelessWidget {
  const LabelEditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.label, size: 64, color: Colors.amber),
        const SizedBox(height: 16),
        const Text(
          "Label setup will go here.",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            "file": null, // TODO: pass actual file path if needed
            "task_type": null, // TODO: pass actual task type if needed
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            "Finish",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
