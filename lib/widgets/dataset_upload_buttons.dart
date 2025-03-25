import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/media_item.dart';
import '../data/dataset_database.dart';

class DatasetUploadButtons extends StatelessWidget {
  final int project_id;
  final String dataset_id;

  final bool isUploading;
  final bool cancelUpload;

  final Function(bool) onUploadingChanged;
  final VoidCallback onUploadSuccess;
  final void Function(String filename, int index, int total)? onFileProgress;
  final VoidCallback? onUploadError;

  const DatasetUploadButtons({
    required this.project_id,
    required this.dataset_id,
    required this.isUploading,
    required this.onUploadingChanged,
    required this.onUploadSuccess,
    this.onFileProgress,
    this.onUploadError,
    required this.cancelUpload,
    super.key,
  });

  Future<void> _uploadMedia(BuildContext context) async {
    onUploadingChanged(true);

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      );

      if (result != null && result.files.isNotEmpty) {
        final total = result.files.length;

        for (int i = 0; i < total; i++) {
          if (cancelUpload) {
            onUploadingChanged(false);
            onUploadError?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Upload stopped")),
            );
            return;
          }

          final file = result.files[i];
          final ext = file.extension?.toLowerCase();
          final type = (ext == 'mp4' || ext == 'mov')
              ? MediaType.video
              : MediaType.image;

          final mediaItem = MediaItem(
            id: const Uuid().v4(),
            datasetId: dataset_id,
            filePath: file.path!,
            type: type,
          );

          await DatasetDatabase.instance.insertMediaItem(mediaItem);

          onFileProgress?.call(file.name, i + 1, total);
        }

        onUploadSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload cancelled")),
        );
        onUploadingChanged(false);
      }
    } catch (e) {
      print("Upload error: $e");
      onUploadError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      height: 120,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildButton(
            context,
            label: "Upload dataset",
            borderColor: Colors.grey,
          ),
          SizedBox(width: 16),
          _buildButton(
            context,
            label: "Upload media",
            borderColor: Colors.red,
          ),
        ],
      ),
    );
  }

Widget _buildButton(
  BuildContext context, {
  required String label,
  required Color borderColor,
}) {
  return ElevatedButton(
    onPressed: isUploading
        ? null // 👉 блокируем во время загрузки
        : () async {
            await _uploadMedia(context);
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[900],
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: borderColor, width: 2),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
}
