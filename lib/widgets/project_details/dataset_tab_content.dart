import 'package:flutter/material.dart';

import '../../models/annotated_labeled_media.dart';
import '../../models/label.dart';
import '../../models/project.dart';

import '../dialogs/delete_image_dialog.dart';

import 'dataset_upload_buttons.dart';
import 'paginated_image_grid.dart';
import '../dialogs/no_media_dialog.dart';

class DatasetTabContent extends StatefulWidget {
  final Project project;
  final String datasetId;
  final List<Label> labels;
  final List<AnnotatedLabeledMedia>? mediaItems;
  final int fileCount;
  final int totalPages;
  final int currentPage;
  final int itemsPerPage;
  final bool isUploading;
  final bool cancelUpload;

  final VoidCallback onUploadSuccess;
  final VoidCallback onUploadError;
  final Function(bool) onUploadingChanged;

  final void Function(AnnotatedLabeledMedia media, bool withAnnotations)? onImageDuplicated;
  final void Function(String filename, int index, int total) onFileProgress;
  final void Function(int newItemsPerPage) onItemsPerPageChanged;

  // Callback to notify when the page changes
  final void Function(int newPage) onPageChanged;

  // Callback to notify when media items changed, i.e. deleted
  final VoidCallback onMediaDeleted;

  const DatasetTabContent({
    super.key,
    required this.project,
    required this.datasetId,
    required this.labels,
    required this.mediaItems,
    required this.fileCount,
    required this.totalPages,
    required this.currentPage,
    required this.itemsPerPage,
    required this.isUploading,
    required this.cancelUpload,
    required this.onUploadingChanged,
    required this.onUploadSuccess,
    required this.onFileProgress,
    required this.onUploadError,
    required this.onPageChanged,
    required this.onMediaDeleted,
    required this.onItemsPerPageChanged,
    this.onImageDuplicated,
  });

  @override
  State<DatasetTabContent> createState() => _DatasetTabContentState();
}

class _DatasetTabContentState extends State<DatasetTabContent> {
  List<AnnotatedLabeledMedia> _selectedItems = [];
  final bool allSelected = false;
  late int _currentItemsPerPage;

  @override
  void initState() {
    super.initState();
    _currentItemsPerPage = widget.itemsPerPage;
  }

  void _handleSelectionChanged(List<AnnotatedLabeledMedia> selected) {
    setState(() {
      _selectedItems = selected;
    });
  }

  void _handleToggleSelectAll() {
    final currentItems = List<AnnotatedLabeledMedia>.from(widget.mediaItems ?? []);
    final allSelected = currentItems.every((item) => (item.isSelected == true));
    for (final item in currentItems) {
      item.isSelected = !allSelected;
    }
    _handleSelectionChanged(currentItems);
  }

  void _handleDeleteSelected() async {
    if (_selectedItems.isEmpty) return;

    final deletedPaths = await showDialog<List<String>>(
      context: context,
      builder: (context) => DeleteImageDialog(
        mediaItems: _selectedItems.map((e) => e.mediaItem).toList(),
        onConfirmed: (deletedPaths) => Navigator.pop(context, deletedPaths),
      ),
    );

    if (deletedPaths != null && deletedPaths.isNotEmpty) {
      // Immediately remove deleted items from the current view
      setState(() {
        _selectedItems.removeWhere((item) => deletedPaths.contains(item.mediaItem.filePath));
      });

      // Refresh the page after deletion
      widget.onMediaDeleted();
    }
  }

  void _handleItemsPerPageChanged(int newItemsPerPage) {
    widget.onItemsPerPageChanged(newItemsPerPage);
    setState(() {
      _currentItemsPerPage = newItemsPerPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DatasetUploadButtons(
          project: widget.project,
          datasetId: widget.datasetId,
          totalCount: widget.fileCount,
          itemsPerPage: widget.itemsPerPage,
          isUploading: widget.isUploading,
          onUploadingChanged: widget.onUploadingChanged,
          onUploadSuccess: widget.onUploadSuccess,
          onFileProgress: widget.onFileProgress,
          onUploadError: widget.onUploadError,
          cancelUpload: widget.cancelUpload,
          selectedCount: _selectedItems.length,
          allSelected: (widget.mediaItems ?? []).every((item) => item.isSelected == true),
          onDeleteSelected: _handleDeleteSelected,
          onToggleSelectAll: _handleToggleSelectAll,
          onItemsPerPageChanged: _handleItemsPerPageChanged,
        ),
        Expanded(
          child: widget.mediaItems == null
              ? const Center(child: CircularProgressIndicator())
              : widget.mediaItems!.isEmpty
                  ? NoMediaDialog(
                      projectId: widget.project.id!,
                      datasetId: widget.datasetId,
                    )
                  : PaginatedImageGrid(
                      project: widget.project,
                      datasetId: widget.datasetId,
                      labels: widget.labels,
                      annotatedMediaItems: widget.mediaItems!,
                      totalCount: widget.fileCount,
                      totalPages: widget.totalPages,
                      currentPage: widget.currentPage,
                      itemsPerPage: _currentItemsPerPage,
                      onPageChanged: widget.onPageChanged,
                      onSelectionChanged: _handleSelectionChanged,
                      onImageDuplicated: (media, withAnnotations) {
                        widget.onImageDuplicated?.call(media, withAnnotations);
                      },
                    ),
        ),
      ],
    );
  }
}
