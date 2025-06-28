import 'package:flutter/material.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import 'annotated_list_item.dart';

class AnnotatorRightSidebar extends StatefulWidget {
  final bool collapsed;
  final List<Label> labels;
  final List<Annotation> annotations;
  final Function(Annotation?)? onAnnotationSelected;
  final Function(Annotation, Label) onAnnotationLabelChanged;
  final Function(Annotation) onAnnotationDelete;
  final Annotation? selectedAnnotation;

  const AnnotatorRightSidebar({
    super.key,
    required this.collapsed,
    required this.labels,
    required this.annotations,
    required this.onAnnotationSelected,
    required this.onAnnotationLabelChanged,
    required this.onAnnotationDelete,
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
              child: Text(
                "Annotations (${widget.annotations.length})",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
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
