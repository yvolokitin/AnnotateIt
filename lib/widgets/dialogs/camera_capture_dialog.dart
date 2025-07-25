import 'dart:io';

import 'package:flutter/material.dart';
import '../camera/camera_capture_widget.dart';

class CameraCaptureDialog extends StatelessWidget {
  final Function(File file, String fileType) onMediaCaptured;

  const CameraCaptureDialog({
    Key? key,
    required this.onMediaCaptured,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: CameraCaptureWidget(
        onMediaCaptured: (file, fileType) {
          // Close the dialog and pass the captured media back
          Navigator.of(context).pop();
          onMediaCaptured(file, fileType);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Helper method to show the dialog
  static Future<void> show(
    BuildContext context, {
    required Function(File file, String fileType) onMediaCaptured,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CameraCaptureDialog(
          onMediaCaptured: onMediaCaptured,
        );
      },
    );
  }
}