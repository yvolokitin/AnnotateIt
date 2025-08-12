import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../gen_l10n/app_localizations.dart';
import 'annotated_list_item.dart';

class AnnotatorRightSidebar extends StatefulWidget {
  final bool collapsed;
  final List<Label> labels;
  final List<Annotation> annotations;
  final Function(Annotation?)? onAnnotationSelected;
  final Function(Annotation, Label) onAnnotationLabelChanged;
  final Function(Annotation) onAnnotationDelete;
  final VoidCallback? onDeleteAll;
  final Annotation? selectedAnnotation;

  const AnnotatorRightSidebar({
    super.key,
    required this.collapsed,
    required this.labels,
    required this.annotations,
    required this.onAnnotationSelected,
    required this.onAnnotationLabelChanged,
    required this.onAnnotationDelete,
    this.onDeleteAll,
    this.selectedAnnotation,
  });

  @override
  State<AnnotatorRightSidebar> createState() => _AnnotatorRightSidebarState();
}

class _AnnotatorRightSidebarState extends State<AnnotatorRightSidebar> {
  int? _hoveredIndex;

  void _handleAnnotationTap(Annotation annotation) {
    widget.onAnnotationSelected?.call(
      widget.selectedAnnotation == annotation ? null : annotation
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.collapsed ? 0 : 250,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          left: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 4,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.collapsed) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${l10n.annotations} (${widget.annotations.length})",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: (screenWidth > 700) ? 18 : 16,
                      fontFamily: 'CascadiaCode',
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (widget.annotations.isNotEmpty)
                    Tooltip(
                      message: l10n.deleteAllAnnotations,
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorScheme.error,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) {
                              final screenWidth = MediaQuery.of(ctx).size.width;
                              final isLargeScreen = screenWidth > 700;
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.redAccent, width: 1),
                                ),
                                titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.delete_sweep_outlined,
                                          size: 32,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          l10n.deleteAllAnnotations,
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontFamily: 'CascadiaCode',
                                            fontWeight: FontWeight.bold,
                                            fontSize: isLargeScreen ? 24 : 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.redAccent),
                                      tooltip: l10n.buttonClose,
                                      onPressed: () => Navigator.pop(ctx, false),
                                    ),
                                  ],
                                ),
                                content: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Divider(color: Colors.redAccent),
                                        Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Text(
                                            l10n.deleteAllAnnotationsConfirm,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontFamily: 'CascadiaCode',
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const Divider(color: Colors.redAccent),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: Colors.white70, width: 2),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.buttonCancel,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'CascadiaCode',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: Colors.redAccent, width: 2),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.buttonDelete,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'CascadiaCode',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmed == true) {
                            widget.onDeleteAll?.call();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                        splashRadius: 18,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: widget.annotations.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildAnnotationsList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "No annotations yet",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
            fontFamily: 'CascadiaCode',
          ),
        ),
      ),
    );
  }

  Widget _buildAnnotationsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: widget.annotations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final annotation = widget.annotations[index];
        final isSelected = widget.selectedAnnotation == annotation;
        final isHovered = _hoveredIndex == index;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: AnnotatedListItem(
            annotation: annotation,
            isSelected: isSelected,
            isHovered: isHovered,
            onTap: () => _handleAnnotationTap(annotation),
            onLabelChanged: (newLabel) => widget.onAnnotationLabelChanged(annotation, newLabel),
            onDelete: widget.onAnnotationDelete,
            theme: Theme.of(context),
            availableLabels: widget.labels,
          ),
        );
      },
    );
  }
}
