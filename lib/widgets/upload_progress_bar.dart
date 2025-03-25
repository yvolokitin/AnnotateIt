import 'package:flutter/material.dart';

class UploadProgressBar extends StatelessWidget {
  final String filename;
  final double progress; // от 0 до 1
  final bool success;
  final bool error;
  final VoidCallback? onCancel;

  const UploadProgressBar({
    required this.filename,
    required this.progress,
    this.success = false,
    this.error = false,
    this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.blue;
    if (success) backgroundColor = Colors.green;
    if (error) backgroundColor = Colors.red;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: backgroundColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filename,
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    color: backgroundColor,
                    backgroundColor: Colors.grey[800],
                  ),
                ],
              ),
            ),
            if (!success && !error)
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: onCancel,
              ),
            if (success)
              Icon(Icons.check_circle, color: Colors.green),
            if (error)
              Icon(Icons.error_outline, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
