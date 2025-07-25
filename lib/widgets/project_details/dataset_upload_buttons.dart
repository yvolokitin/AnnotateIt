import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../../gen_l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../utils/image_utils.dart';
import '../../data/dataset_database.dart';
import '../../data/project_database.dart';
import '../../session/user_session.dart';
import '../dialogs/camera_capture_dialog.dart';

class DatasetUploadButtons extends StatefulWidget {
  final Project project;
  final int totalCount, itemsPerPage;
  final int selectedCount;
  final String datasetId;

  final bool isUploading;
  final bool cancelUpload;
  final bool allSelected;

  final Function(bool) onUploadingChanged;
  final VoidCallback onUploadSuccess;
  final void Function(String filename, int index, int total)? onFileProgress;
  final void Function(int newItemsPerPage)? onItemsPerPageChanged;
  final VoidCallback? onUploadError;

  final VoidCallback? onDeleteSelected;
  final VoidCallback? onToggleSelectAll;

  const DatasetUploadButtons({
    required this.project,
    required this.datasetId,
    required this.totalCount,
    required this.itemsPerPage,
    required this.isUploading,
    required this.onUploadingChanged,
    required this.onUploadSuccess,
    required this.cancelUpload,
    required this.selectedCount,
    required this.allSelected,
    this.onFileProgress,
    this.onUploadError,
    this.onDeleteSelected,
    this.onToggleSelectAll,
    this.onItemsPerPageChanged,
    super.key,
  });

  @override
  State<DatasetUploadButtons> createState() => _DatasetUploadButtonsState();
}

class _DatasetUploadButtonsState extends State<DatasetUploadButtons> {
  bool _hoveringDelete = false;
  late int _currentItemsPerPage;

  @override
  void initState() {
    super.initState();
    _currentItemsPerPage = widget.itemsPerPage;
  }

  Future<void> _uploadMedia(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      );

      if (result != null && result.files.isNotEmpty) {
        widget.onUploadingChanged(true);
        final total = result.files.length;

        if (widget.project.icon.contains('default_project_image') ||
            widget.project.icon.contains('folder')) {
          final platformFile = result.files[0];
          final thumbnailFile = await generateThumbnailFromImage(
              File(platformFile.path!), widget.project.id.toString());
          if (thumbnailFile != null) {
            await ProjectDatabase.instance
                .updateProjectIcon(widget.project.id!, thumbnailFile.path);
          }
        }

        for (int i = 0; i < total; i++) {
          if (widget.cancelUpload) {
            widget.onUploadingChanged(false);
            widget.onUploadError?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Upload stopped")),
            );
            return;
          }

          final file = result.files[i];
          final ext = file.extension?.toLowerCase() ?? 'unknown';
          final currentUser = UserSession.instance.getUser();
          if (currentUser.id == null) {
            widget.onUploadError?.call();
            return;
          }

          int? width;
          int? height;
          double? duration;
          double? fps;
          final isVideo = ['mp4', 'mov'].contains(ext);

          if (isVideo) {
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
            widget.datasetId,
            file.path!,
            ext,
            ownerId: currentUser.id!,
            width: width,
            height: height,
            duration: duration,
            fps: fps,
            source: 'local',
          );

          widget.onFileProgress?.call(file.name, i + 1, total);
        }

        await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
        widget.onUploadingChanged(false);
        widget.onUploadSuccess();
      } else {
        widget.onUploadingChanged(false);
      }
    } catch (e) {
      print("_uploadMedia: Upload error: $e");
      widget.onUploadError?.call();
    }
  }
  
  Future<void> _openCamera(BuildContext context) async {
    try {
      // Check if running on Linux
      if (Platform.isLinux) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Camera functionality is not supported on Linux"),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // Note: Windows platform is handled in camera_capture_widget.dart
      // by using image_picker instead of direct camera access
      
      widget.onUploadingChanged(true);
      
      await CameraCaptureDialog.show(
        context,
        onMediaCaptured: (File file, String fileType) async {
          final filename = path.basename(file.path);
          final ext = fileType.toLowerCase();
          
          final currentUser = UserSession.instance.getUser();
          if (currentUser.id == null) {
            widget.onUploadError?.call();
            return;
          }
          
          int? width;
          int? height;
          double? duration;
          double? fps;
          final isVideo = ext == 'mp4';
          
          if (isVideo) {
            final videoMeta = await getVideoMetadata(file.path);
            width = videoMeta['width'];
            height = videoMeta['height'];
            duration = videoMeta['duration'];
            fps = videoMeta['fps'];
          } else {
            final imageMeta = await getImageMetadata(file.path);
            width = imageMeta['width'];
            height = imageMeta['height'];
          }
          
          await DatasetDatabase.instance.insertMediaItem(
            widget.datasetId,
            file.path,
            ext,
            ownerId: currentUser.id!,
            width: width,
            height: height,
            duration: duration,
            fps: fps,
            source: 'camera',
          );
          
          widget.onFileProgress?.call(filename, 1, 1);
          
          // Update project icon if needed
          if (widget.project.icon.contains('default_project_image') ||
              widget.project.icon.contains('folder')) {
            if (!isVideo) {
              final thumbnailFile = await generateThumbnailFromImage(
                  file, widget.project.id.toString());
              if (thumbnailFile != null) {
                await ProjectDatabase.instance
                    .updateProjectIcon(widget.project.id!, thumbnailFile.path);
              }
            }
          }
          
          await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
          widget.onUploadingChanged(false);
          widget.onUploadSuccess();
        },
      );
      
      // If we get here without capturing media, reset the uploading state
      if (widget.isUploading) {
        widget.onUploadingChanged(false);
      }
    } catch (e) {
      print("_openCamera: Camera error: $e");
      widget.onUploadingChanged(false);
      widget.onUploadError?.call();
      
      // Show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Camera Error: ${e.toString().split('\n')[0]}"),
          duration: const Duration(seconds: 3),
        ),
      );
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
    // print('getVideoMetadata (stub with zeros) called for: $path');
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showDeleteButton = widget.allSelected || ((widget.selectedCount < widget.itemsPerPage) && (widget.allSelected == false));

    return Container(
      height: screenWidth>1200 ? 120 : screenWidth>650 ? 80 : 60,
      width: double.infinity,
        child: Row(
        children: [
          if (widget.totalCount > 0) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: Icon(
                  widget.allSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                  color: Colors.white70,
                  size: 24,
                ),
                onPressed: widget.onToggleSelectAll,
              ),
            ),
            SizedBox(width: screenWidth > 700 ? 20 : 10),
            Text(
              screenWidth > 1190 ? "${widget.totalCount} files" : "${widget.totalCount}",
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth > 900 ? 22 : 18,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ],

          if (showDeleteButton && widget.selectedCount > 0) ...[
            Text(
              screenWidth > 1190 ? " / ${widget.selectedCount} selected " : " / ${widget.selectedCount}",
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth > 900 ? 22 : 18,
                fontFamily: 'CascadiaCode',
              ),
            ),
            SizedBox(width: screenWidth > 700 ? 20 : 10),
            MouseRegion(
              onEnter: (_) => setState(() => _hoveringDelete = true),
              onExit: (_) => setState(() => _hoveringDelete = false),
              cursor: SystemMouseCursors.click,
              child: AnimatedScale(
                scale: _hoveringDelete ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: _hoveringDelete
                        ? const Color(0x26FF0000)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: _hoveringDelete ? Colors.redAccent : Colors.white70,
                    ),
                    tooltip: l10n.buttonDelete,
                    onPressed: widget.onDeleteSelected,
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),

          if (screenWidth > 1024)...[
            const SizedBox(width: 20),
            DropdownButton<int>(
              value: _currentItemsPerPage,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              iconEnabledColor: Colors.white,
              underline: Container(height: 0),
              items: [8, 16, 24, 36, 48].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    '$value per page',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != _currentItemsPerPage) {
                  setState(() {
                    _currentItemsPerPage = value;
                  });
                  widget.onItemsPerPageChanged?.call(value);
                }
              },
            ),
          ],

          SizedBox(width: screenWidth > 700 ? 20 : 10),
          _buildButton(
            context,
            buttonName: l10n.importDataset,
            buttonIcon: Icons.upload,
            borderColor: Colors.white70,
          ),

          SizedBox(width: screenWidth > 700 ? 20 : 10),
          _buildButton(
            context,
            buttonName: l10n.uploadMedia,
            buttonIcon: Icons.add_to_photos,
            borderColor: Colors.red,
            onPressed: () async {
              await _uploadMedia(context);
            },
          ),
          
          SizedBox(width: screenWidth > 700 ? 20 : 10),
          _buildButton(
            context,
            buttonName: 'Camera',
            buttonIcon: Icons.camera_alt,
            borderColor: Colors.blue,
            onPressed: Platform.isLinux ? null : () async {
              await _openCamera(context);
            },
            tooltip: Platform.isLinux ? 'Camera not supported on Linux' : null,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String buttonName,
    required IconData buttonIcon,
    required Color borderColor,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultOnPressed = () async {
      await _uploadMedia(context);
    };
    
    final buttonOnPressed = widget.isUploading
        ? null
        : (onPressed ?? defaultOnPressed);
    
    if (screenWidth < 1024) {
      return Tooltip(
        message: tooltip ?? buttonName,
        child: ElevatedButton(
          onPressed: buttonOnPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(14),
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: buttonOnPressed == null ? Colors.grey : borderColor, 
              width: 1
            ),
          ),
          child: Icon(
            buttonIcon,
            color: buttonOnPressed == null ? Colors.grey : borderColor,
            size: screenWidth > 700 ? 30 : 24),
        ),
      );

    } else {
      return Tooltip(
        message: tooltip ?? buttonName,
        child: ElevatedButton(
          onPressed: buttonOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: buttonOnPressed == null ? Colors.grey : borderColor, 
                width: 2
              ),
            ),
          ),
          child: Text(
            buttonName,
            style: TextStyle(
              color: buttonOnPressed == null ? Colors.grey : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
      );
    }
  }
}
