import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Added Riverpod import
import 'package:uuid/uuid.dart';

import '../utils/image_utils.dart';
import '../data/app_database.dart';
import '../data/providers.dart';

class DatasetUploadButtons extends ConsumerWidget {  // Changed to ConsumerWidget
  final int project_id, file_count;
  final String project_icon;
  final String dataset_id;

  final bool isUploading;
  final bool cancelUpload;

  final Function(bool) onUploadingChanged;
  final VoidCallback onUploadSuccess;
  final void Function(String filename, int index, int total)? onFileProgress;
  final VoidCallback? onUploadError;

  const DatasetUploadButtons({
    required this.project_id,
    required this.project_icon,
    required this.dataset_id,
    required this.file_count,
    required this.isUploading,
    required this.onUploadingChanged,
    required this.onUploadSuccess,
    this.onFileProgress,
    this.onUploadError,
    required this.cancelUpload,
    super.key,
  });

  Future<void> _uploadMedia(BuildContext context, WidgetRef ref) async {  // Added WidgetRef ref
    print("UI _uploadMedia: Uploading media... for dataset_id: $dataset_id");

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      );

      if (result != null && result.files.isNotEmpty) {
        onUploadingChanged(true);
        final total = result.files.length;

        if (project_icon.contains('default_project_image') || project_icon.contains('folder')) {
          final platformFile = result.files[0];
          final thumbnailFile = await generateThumbnailFromImage(File(platformFile.path!), project_id.toString());
          if (thumbnailFile != null) {
            await ref.read(databaseProvider).updateProjectIcon(project_id, thumbnailFile.path);
          }
        }

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
          final ext = file.extension?.toLowerCase() ?? 'unknown';
          await ref.read(databaseProvider).insertMediaItem(dataset_id, file.path!, ext);

          onFileProgress?.call(file.name, i + 1, total);
        }

        await ref.read(databaseProvider).updateProjectlastUpdated(project_id);
        onUploadingChanged(false); 
        onUploadSuccess();
      } else {
        onUploadingChanged(false);
      }
    } catch (e) {
      print("_uploadMedia: Upload error: $e");
      onUploadError?.call();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // Added WidgetRef ref
    return Container(
      padding: EdgeInsets.all(40),
      height: 120,
      width: double.infinity,
      child: Row(
        children: [
          Text("$file_count files", style: TextStyle(color: Colors.white, fontSize: 20)),
          Spacer(), // takes all available space between the text and buttons

          SizedBox(width: 20),
          _buildButton(
            context,
            ref,  // Added ref to button
            label: "Import dataset",
            borderColor: Colors.grey,
          ),

          SizedBox(width: 20),
          _buildButton(
            context,
            ref,  // Added ref to button
            label: "Upload media",
            borderColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    WidgetRef ref,  // Added ref
    {
    required String label,
    required Color borderColor,
  }) {
    return ElevatedButton(
      onPressed: isUploading
          ? null // block during upload
          : () async {
              await _uploadMedia(context, ref);  // Added ref to function call
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
