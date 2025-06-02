import 'dart:io';
import 'package:vap/gen_l10n/app_localizations.dart';
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";

import "../../utils/image_utils.dart";
import "../../data/dataset_database.dart";
import "../../data/project_database.dart";

import "../../session/user_session.dart";

class DatasetUploadButtons extends StatelessWidget {
  final int project_id, file_count;
  final String project_icon;
  final String dataset_id;

  final bool isUploading;
  final bool cancelUpload;

  final Function(bool) onUploadingChanged;
  final VoidCallback onUploadSuccess;
  final void Function(String filename, int index, int total)? onFileProgress;
  final VoidCallback? onUploadError;

  final int selectedCount;
  final VoidCallback? onDeleteSelected;

  const DatasetUploadButtons({
    required this.project_id,
    required this.project_icon,
    required this.dataset_id,
    required this.file_count,
    required this.isUploading,
    required this.onUploadingChanged,
    required this.onUploadSuccess,
    required this.cancelUpload,
    required this.selectedCount,
    this.onFileProgress,
    this.onUploadError,
    this.onDeleteSelected,
    super.key,
  });

  Future<void> _uploadMedia(BuildContext context) async {
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
            await ProjectDatabase.instance.updateProjectIcon(project_id, thumbnailFile.path);
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
          final currentUser = UserSession.instance.getUser();
          if (currentUser.id == null) {
            onUploadError?.call();
            return;
          }

          int? width;
          int? height;
          double? duration;
          double? fps;
          final isVideo = ['mp4', 'mov'].contains(ext);
  
          if (isVideo) {
            // TODO: Replace with actual video metadata extractor
            final videoMeta = await getVideoMetadata(file.path!);
            width = videoMeta['width'];
            height = videoMeta['height'];
            duration = videoMeta['duration'];
            fps = videoMeta['fps'];
  
          } else {
            final imageMeta = await getImageMetadata(file.path!);
            width = imageMeta['width'];
            height = imageMeta['height'];
          }

          await DatasetDatabase.instance.insertMediaItem(
            dataset_id,
            file.path!,
            ext,
            ownerId: currentUser.id!,
            width: width,
            height: height,
            duration: duration,
            fps: fps,
            source: 'local',
          );
  
          onFileProgress?.call(file.name, i + 1, total);
        }

        await ProjectDatabase.instance.updateProjectLastUpdated(project_id);
        onUploadingChanged(false); onUploadSuccess();

      } else {
        onUploadingChanged(false);
      }
    } catch (e) {
      print("_uploadMedia: Upload error: $e");
      onUploadError?.call();
    }
  }

  Future<Map<String, dynamic>> getImageMetadata(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);
    return {
      'width': decodedImage.width,
      'height': decodedImage.height,
    };
  }

  Future<Map<String, dynamic>> getVideoMetadata(String path) async {
    print('getVideoMetadata (stub with zeros) called for: $path');
    return {
      'width': 0,
      'height': 0,
      'duration': 0.0,
      'fps': 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    print('1111111 selectedCount: $selectedCount');
    return Container(
      padding: EdgeInsets.all(40),
      height: 120,
      width: double.infinity,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            selectedCount > 0
              ? "$file_count files / $selectedCount selected"
              : "$file_count files",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),

          if (selectedCount > 0)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: "Delete selected",
              onPressed: onDeleteSelected,
            ),

          Spacer(), // takes all available space between the text and buttons

          SizedBox(width: 20),
          _buildButton(
            context,
            label: l10n.importDataset,
            borderColor: Colors.grey,
          ),

          SizedBox(width: 20),
          _buildButton(
            context,
            label: l10n.uploadMedia,
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
  final screenWidth = MediaQuery.of(context).size.width;
  final bool isCompact = screenWidth < 750;

  final IconData icon = label.toLowerCase().contains("upload")
      ? Icons.upload
      : Icons.dataset;

  if (isCompact) {
    // Icon-only button for small screens
    return IconButton(
      onPressed: isUploading
          ? null
          : () async {
              await _uploadMedia(context);
            },
      icon: Icon(icon, color: Colors.white, size: 36),
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey[900],
        shape: CircleBorder(
          side: BorderSide(color: borderColor, width: 2),
        ),
      ),
    );
  } else {
    // Text-only button for large screens
    return ElevatedButton(
      onPressed: isUploading
          ? null
          : () async {
              await _uploadMedia(context);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[900],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

}
