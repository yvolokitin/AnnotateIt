import 'package:flutter/material.dart';

import '../../models/annotated_labeled_media.dart';
import '../../models/media_item.dart';
import '../../models/project.dart';
import '../../models/dataset.dart';

import 'dataset_upload_buttons.dart';
import 'paginated_image_grid.dart';
import 'no_media_dialog.dart';

class DatasetTabContent extends StatelessWidget {
  final Project project;
  final Dataset dataset;
  final List<AnnotatedLabeledMedia>? mediaItems;
  final int fileCount;
  final int totalPages;
  final int currentPage;
  final bool isUploading;
  final bool cancelUpload;
  final int selectedCount;

  final VoidCallback onUploadSuccess;
  final VoidCallback onUploadError;
  final Function(bool) onUploadingChanged;
  final void Function(String filename, int index, int total) onFileProgress;
  final void Function(int newPage) onPageChanged;
  final void Function(List<AnnotatedLabeledMedia>) onSelectionChanged;
  final VoidCallback onDeleteSelected;

  const DatasetTabContent({
    super.key,
    required this.project,
    required this.dataset,
    required this.mediaItems,
    required this.fileCount,
    required this.totalPages,
    required this.currentPage,
    required this.isUploading,
    required this.cancelUpload,
    required this.selectedCount,
    required this.onUploadingChanged,
    required this.onUploadSuccess,
    required this.onFileProgress,
    required this.onUploadError,
    required this.onPageChanged,
    required this.onSelectionChanged,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DatasetUploadButtons(
          project_id: project.id!,
          project_icon: project.icon,
          dataset_id: dataset.id,
          file_count: fileCount,
          isUploading: isUploading,
          onUploadingChanged: onUploadingChanged,
          onUploadSuccess: onUploadSuccess,
          onFileProgress: onFileProgress,
          onUploadError: onUploadError,
          cancelUpload: cancelUpload,
          selectedCount: selectedCount,
          onDeleteSelected: onDeleteSelected,
        ),
        Expanded(
          child: mediaItems == null
              ? const Center(child: CircularProgressIndicator())
              : mediaItems!.isEmpty
                  ? NoMediaDialog(
                      project_id: project.id!,
                      dataset_id: dataset.id,
                    )
                  : PaginatedImageGrid(
                      annotatedMediaItems: mediaItems!,
                      totalCount: fileCount,
                      totalPages: totalPages,
                      currentPage: currentPage,
                      project: project,
                      onPageChanged: onPageChanged,
                      onSelectionChanged: onSelectionChanged,
                    ),
        ),
      ],
    );
  }
}
