// widgets/step_description_widget.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StepDescriptionWidget extends StatelessWidget {
  final int currentStep;
  final String? extractedPath;
  final String? detectedTaskType;

  const StepDescriptionWidget({
    super.key,
    required this.currentStep,
    this.extractedPath,
    this.detectedTaskType,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStep == 1) {
      return const Text(
        "Upload a .ZIP file with COCO, YOLO, VOC, LabelMe, CVAT, Datumaro or media-only format",
        style: TextStyle(fontSize: 22, color: Colors.white70),
      );
    } else if (currentStep == 2) {
      return const Text(
        "Extracting ZIP in local storage ...",
        style: TextStyle(fontSize: 22, color: Colors.white70),
      );
    } else if (currentStep == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              if (extractedPath != null) {
                await launchUrl(Uri.file(extractedPath!), mode: LaunchMode.platformDefault);
              }
            },
            child: Text(
              "Dataset extracted in: $extractedPath",
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Detected task type: $detectedTaskType",
            style: const TextStyle(fontSize: 22, color: Colors.white70),
          ),
        ],
      );
    } else {
      return const Text(
        "Edit your project labels",
        style: TextStyle(fontSize: 22, color: Colors.white70),
      );
    }
  }
}
