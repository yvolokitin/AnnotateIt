import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../../widgets/project_creation/dataset_step_progress_bar.dart';
import '../../../utils/responsive_utils.dart';

class CreateFromDatasetDialog extends StatefulWidget {
  const CreateFromDatasetDialog({super.key});

  @override
  State<CreateFromDatasetDialog> createState() => _CreateFromDatasetDialogState();
}

class _CreateFromDatasetDialogState extends State<CreateFromDatasetDialog> {
  File? _droppedFile;
  bool _isDragging = false;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
    if (result != null && result.files.single.path != null) {
      setState(() => _droppedFile = File(result.files.single.path!));
    }
  }

  void _handleFileDrop(File file) {
    if (file.path.endsWith(".zip")) {
      setState(() => _droppedFile = file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceType = getDeviceType(size.width);

    double dialogWidth;
    EdgeInsetsGeometry padding;

    switch (deviceType) {
      case DeviceType.desktop:
        dialogWidth = size.width * 0.6;
        padding = const EdgeInsets.all(32);
        break;
      case DeviceType.tablet:
        dialogWidth = size.width * 0.85;
        padding = const EdgeInsets.all(24);
        break;
      case DeviceType.mobile:
      default:
        dialogWidth = size.width;
        padding = const EdgeInsets.all(16);
        break;
    }

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: dialogWidth,
        height: size.height * 0.9,
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create project from a dataset - Import",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const DatasetStepProgressBar(),
              const SizedBox(height: 24),
              _buildDropArea(context),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text("Hide", style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropArea(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: DragTarget<File>(
        onWillAccept: (data) => true,
        onAccept: _handleFileDrop,
        onMove: (_) => setState(() => _isDragging = true),
        onLeave: (_) => setState(() => _isDragging = false),
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _isDragging ? Colors.blue.withAlpha(30) : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  _droppedFile != null
                      ? _droppedFile!.path.split("/").last
                      : "Drop the dataset .zip file here",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text("Upload", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 8),
                const Text("(COCO, YOLO, VOC, Datumaro) .zip",
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                TextButton(
                  onPressed: () {},
                  child: const Text("Learn more...", style: TextStyle(color: Colors.lightBlueAccent)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
