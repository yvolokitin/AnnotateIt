import 'package:flutter/material.dart';

import '../../data/dataset_database.dart';

import '../../models/annotated_labeled_media.dart';
import '../../models/project.dart';
import '../../models/dataset.dart';

import '../dialogs/delete_image_dialog.dart';

import 'dataset_upload_buttons.dart';
import 'paginated_image_grid.dart';
import 'no_media_dialog.dart';

class DatasetTabContent extends StatefulWidget {
  final Project project;
  final Dataset dataset;
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

  final void Function(String filename, int index, int total) onFileProgress;
  final void Function(int newItemsPerPage) onItemsPerPageChanged;

  // Callback to notify when the page changes
  final void Function(int newPage) onPageChanged;

  // Callback to notify when media items changed, i.e. deleted
  final VoidCallback onMediaDeleted;

  const DatasetTabContent({
    super.key,
    required this.project,
    required this.dataset,
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteImageDialog(
        mediaItems: _selectedItems.map((e) => e.mediaItem).toList(),
        onConfirmed: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed == true) {
      for (final media in _selectedItems) {
        await DatasetDatabase.instance.deleteMediaItemWithAnnotations(media.mediaItem.id!);
      }

      setState(() {
        _selectedItems.clear();
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
          project_id: widget.project.id!,
          project_icon: widget.project.icon,
          dataset_id: widget.dataset.id,
          file_count: widget.fileCount,
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
                      project_id: widget.project.id!,
                      dataset_id: widget.dataset.id,
                    )
                  : PaginatedImageGrid(
                      annotatedMediaItems: widget.mediaItems!,
                      totalCount: widget.fileCount,
                      totalPages: widget.totalPages,
                      currentPage: widget.currentPage,
                      itemsPerPage: _currentItemsPerPage,
                      project: widget.project,
                      onPageChanged: widget.onPageChanged,
                      onSelectionChanged: _handleSelectionChanged,
                    ),
        ),
      ],
    );
  }
}
