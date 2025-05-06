import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../../utils/responsive_utils.dart';

class DatasetStepProgressBar extends StatelessWidget {
  final int currentStep;

  const DatasetStepProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStep("1", "Dataset", currentStep == 1),
        _buildLine(),
        _buildStep("2", "Task Type", currentStep == 2),
        _buildLine(),
        _buildStep("3", "Labels", currentStep == 3),
      ],
    );
  }

  Widget _buildStep(String number, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isActive ? Colors.redAccent : Colors.grey[700],
          child: Text(number, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: isActive ? Colors.white : Colors.white54),
        ),
      ],
    );
  }

  Widget _buildLine() => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: 2,
          color: Colors.white24,
        ),
      );
}

class CreateFromDatasetDialog extends StatefulWidget {
  const CreateFromDatasetDialog({super.key});

  @override
  State<CreateFromDatasetDialog> createState() => _CreateFromDatasetDialogState();
}

class _CreateFromDatasetDialogState extends State<CreateFromDatasetDialog> {
  File? _selectedFile;
  bool _isUploading = false;
  int _currentStep = 1;
  String? _detectedTaskType;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() => _selectedFile = file);
      await _uploadZip(file);
    }
  }

  Future<void> _uploadZip(File file) async {
    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse("https://your-api.com/api/upload_dataset");
      final request = http.MultipartRequest("POST", uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        final taskType = data['task_type'];

        setState(() {
          _detectedTaskType = taskType;
          _currentStep = 2;
        });
      } else {
        throw Exception("Upload failed with status ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _goToNextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceType = getDeviceType(size.width);

    double dialogWidth;
    EdgeInsets padding;

    switch (deviceType) {
      case DeviceType.desktop:
        dialogWidth = size.width * 0.9;
        padding = const EdgeInsets.all(60);
        break;
      case DeviceType.tablet:
        dialogWidth = size.width * 0.85;
        padding = const EdgeInsets.all(24);
        break;
      case DeviceType.mobile:
      default:
        dialogWidth = size.width;
        padding = const EdgeInsets.all(12);
        break;
    }

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: SizedBox(
        width: dialogWidth,
        height: size.height * 0.9,
        child: Padding(
          padding: padding,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Import Dataset to Create Project",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentStep == 1
                        ? "Upload a .zip file with COCO, YOLO, VOC, or Datumaro format"
                        : _currentStep == 2
                            ? "Detected task type: $_detectedTaskType"
                            : "Edit your project labels",
                    style: const TextStyle(fontSize: 22, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  DatasetStepProgressBar(currentStep: _currentStep),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: _isUploading
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 5),
                                SizedBox(height: 24),
                                Text("Uploading...", style: TextStyle(color: Colors.white70, fontSize: 18)),
                              ],
                            )
                          : _currentStep == 1
                              ? _buildUploadPrompt()
                              : _currentStep == 2
                                  ? _buildTaskConfirmation()
                                  : _buildLabelEditor(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_detectedTaskType),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Close", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.white70),
        const SizedBox(height: 16),
        const Text(
          "Select your dataset ZIP file to upload",
          style: TextStyle(color: Colors.white70, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _pickFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Choose File", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        const Text("(COCO, YOLO, VOC, Datumaro) .zip only", style: TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }

  Widget _buildTaskConfirmation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 64),
        const SizedBox(height: 16),
        Text("Detected task type: $_detectedTaskType", style: const TextStyle(fontSize: 22, color: Colors.white)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _goToNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Continue", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildLabelEditor() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.label, size: 64, color: Colors.amber),
        const SizedBox(height: 16),
        const Text("Label setup will go here.", style: TextStyle(color: Colors.white, fontSize: 20)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            "file": _selectedFile?.path,
            "task_type": _detectedTaskType,
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Finish", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
