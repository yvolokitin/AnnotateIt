import "package:flutter/material.dart";

// About Widget
class AboutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(56), // 56px padding on all sides
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.red, width: 3), // 3px border
        borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
      ),
      alignment: Alignment.topLeft, // Align text to top-left
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text from the left
        children: [
          Text(
            "About Annot@It",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12), // Spacing between title and body text
          Text(
            "Annot@It is annotation application, which is designed "
            "to streamline the annotation process for computer vision projects. "
            "Whether you're working on image classification, object detection, "
            "segmentation, or other vision tasks, Annot@It provides the flexibility "
            "and precision needed for high-quality data labeling.",
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(height: 12),
          Text(
            "Key Features:",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "• Multiple Project Types – Create and manage projects tailored for different computer vision tasks.\n"
            "• Data Upload & Management – Easily upload and organize your datasets for seamless annotation.\n"
            "• Advanced Annotation Tools – Use bounding boxes, polygons, keypoints, and segmentation masks.\n"
            "• Collaboration & Workflow – Work with teams, assign tasks, and track progress in real-time.\n"
            "• Export & Integration – Export labeled data in various formats compatible with AI/ML frameworks.",
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(height: 12),
          Text(
            "Start your annotation journey today and build high-quality datasets for your computer vision models! 🚀",
            style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
