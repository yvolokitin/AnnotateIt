import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../utils/image_utils.dart';
import '../../data/dataset_database.dart';
import '../../data/project_database.dart';
import '../../session/user_session.dart';

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
    final bool showDeleteButton = widget.allSelected || ((widget.selectedCount < widget.itemsPerPage) && (widget.allSelected == false));

    return Container(
      height: 120,
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
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: widget.onToggleSelectAll,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              "${widget.totalCount} files",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ],

          // if (widget.selectedCount > 0) ...[
          if (showDeleteButton && widget.selectedCount > 0) ...[
            Text(
              " / ${widget.selectedCount} selected",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'CascadiaCode',
              ),
            ),
            const SizedBox(width: 20),
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
                      color: _hoveringDelete ? Colors.redAccent : Colors.white,
                    ),
                    tooltip: l10n.buttonDelete,
                    onPressed: widget.onDeleteSelected,
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),

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

          const SizedBox(width: 20),
          _buildButton(
            context,
            label: l10n.importDataset,
            borderColor: Colors.grey,
          ),

          const SizedBox(width: 20),
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
    final bool isCompact = screenWidth < 1024;

    final IconData icon = label.toLowerCase().contains("upload")
        ? Icons.upload
        : Icons.dataset;

    if (isCompact) {
      return IconButton(
        onPressed: widget.isUploading
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
      return ElevatedButton(
        onPressed: widget.isUploading
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
            fontFamily: 'CascadiaCode',
          ),
        ),
      );
    }
  }
}
