import 'package:flutter/material.dart';

class UploadPrompt extends StatelessWidget {
  final VoidCallback onPickFile;

  const UploadPrompt({super.key, required this.onPickFile});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final iconSize = isDesktop ? 96.0 : isTablet ? 72.0 : 32.0;
    final fontSize = isDesktop ? 22.0 : isTablet ? 20.0 : 18.0;
    final spacing = isDesktop ? 30.0 : isTablet ? 24.0 : 16.0;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 700 : 500),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload_file, size: iconSize, color: Colors.white70),
                SizedBox(height: spacing),
                Text(
                  "Select your Dataset ZIP file",
                  style: TextStyle(color: Colors.white70, fontSize: fontSize),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing),
                ElevatedButton(
                  onPressed: onPickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "Choose a file",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                Text("Supported Dataset formats:",
                    style: TextStyle(color: Colors.white54, fontSize: fontSize),
                    textAlign: TextAlign.center),
                SizedBox(height: spacing / 2),
                Text("COCO, YOLO, VOC, Datumaro,",
                    style: TextStyle(color: Colors.white54, fontSize: fontSize),
                    textAlign: TextAlign.center),
                SizedBox(height: spacing / 2),
                Text("LabelMe, CVAT, or media-only (.zip)",
                    style: TextStyle(color: Colors.white54, fontSize: fontSize),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
