import 'dart:io';
import 'package:flutter/material.dart';

import '../../pages/annotator_page.dart';
import '../project_list/labels_list.dart';

import '../../models/label.dart';
import '../../models/project.dart';
import '../../models/annotation.dart';
import '../../models/annotated_labeled_media.dart';

import 'image_tile/image_preview.dart';
import 'image_tile/image_tile_menu_button.dart';
import 'image_tile/select_checkbox_overlay.dart';
import 'image_tile/error_image_tile.dart';

class ImageTile extends StatefulWidget {
  final Project project;
  final String datasetId;
  final AnnotatedLabeledMedia mediaItem;
  final int pageIndex, pageSize, localIndex;
  final int totalMediaCount;

  final void Function(bool isSelected)? onSelectedChanged;
  final void Function(AnnotatedLabeledMedia media, bool withAnnotations)? onImageDuplicated;

  const ImageTile({
    required this.project,
    required this.datasetId,
    required this.mediaItem,
    required this.pageIndex,
    required this.pageSize,
    required this.localIndex,
    required this.totalMediaCount,
    this.onSelectedChanged,
    this.onImageDuplicated,
    super.key,
  });

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  bool _hovered = false;

  List<Label> extractLabelsFromAnnotations(List<Annotation> annotations) {
    final Map<String, Label> uniqueLabels = {};
    for (final annotation in annotations) {
      final labelName = annotation.name?.trim();
      if (labelName != null && labelName.isNotEmpty && !uniqueLabels.containsKey(labelName)) {
        final labelColor = annotation.color ?? Colors.grey; // fallback
        uniqueLabels[labelName] = Label(
          labelOrder: 0,
          projectId: widget.project.id!,
          name: labelName,
          color: labelColor.value.toRadixString(16).padLeft(8, '0')
        );
      }
    }
    return uniqueLabels.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.mediaItem.mediaItem.filePath);
    final uniqueLabels = extractLabelsFromAnnotations(widget.mediaItem.annotations ?? []);

    if (!file.existsSync()) {
      return const ErrorImageTile(message: "File not found");
    }

    final isSelected = widget.mediaItem.isSelected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.redAccent : Colors.transparent, width: 2),
        ),
        child: ClipRRect(
          child: Stack(
            children: [
              ImagePreview(
                file: file,
                hovered: _hovered,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnnotatorPage(
                      project: widget.project,
                      mediaItem: widget.mediaItem,
                      datasetId: widget.datasetId,
                      pageIndex: widget.pageIndex,
                      pageSize: widget.pageSize,
                      localIndex: widget.localIndex,
                      totalMediaCount: widget.totalMediaCount,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 4,
                left: 4,
                child: SelectCheckboxOverlay(
                  isVisible: _hovered || isSelected,
                  isSelected: isSelected,
                  onTap: () => widget.onSelectedChanged?.call(!isSelected),
                ),
              ),

              Positioned(
                top: 4,
                right: 4,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hovered ? 1.0 : 0.0,
                  child: ImageTileMenuButton(
                    media: widget.mediaItem,
                    onDuplicate: (withAnnotations) => widget.onImageDuplicated?.call(widget.mediaItem, withAnnotations),
                  ),
                ),
              ),

              if (uniqueLabels.length > 0)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: LabelList(
                    labels: uniqueLabels,
                    projectName: widget.project.name,
                    iconPath: widget.project.icon,
                    fontLabelSize: 12,
                    chipBackgroundColor: Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
