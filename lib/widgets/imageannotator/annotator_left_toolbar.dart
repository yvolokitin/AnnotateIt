import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

import '../dialogs/annotations_settings_dialog.dart';
import '../dialogs/alert_error_dialog.dart';

import 'user_action.dart';
import 'toolbar_button.dart';
import 'toolbar_divider.dart';
import 'constants.dart';

class AnnotatorLeftToolbar extends StatefulWidget {
  final String type;
  final double opacity;
  final UserAction selectedAction;
  final bool showAnnotationNames;
  final double strokeWidth;
  final double cornerSize;

  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<double> onStrokeWidthChanged;
  final ValueChanged<double> onCornerSizeChanged;
  final VoidCallback onResetZoomPressed;
  final ValueChanged<bool> onShowDatasetGridChanged;
  final ValueChanged<UserAction> onActionSelected;
  final ValueChanged<bool> onShowAnnotationNames;

  const AnnotatorLeftToolbar({
    super.key,
    required this.type,
    required this.opacity,
    required this.selectedAction,
    required this.showAnnotationNames,
    required this.onOpacityChanged,
    required this.onResetZoomPressed,
    required this.onShowDatasetGridChanged,
    required this.onActionSelected,
    required this.onShowAnnotationNames,
    required this.strokeWidth,
    required this.cornerSize,
    required this.onStrokeWidthChanged,
    required this.onCornerSizeChanged,    
  });

  @override
  State<AnnotatorLeftToolbar> createState() => _AnnotatorLeftToolbarState();
}

class _AnnotatorLeftToolbarState extends State<AnnotatorLeftToolbar> {
  bool showAnnotationsSettingsDialog  = false;
  bool showDatasetGrid = false;

  void _selectUserAction(UserAction action) {
    widget.onActionSelected(action);
  }

  void _openAnnotationsSettingsDialog(BuildContext context) {
    setState(() => showAnnotationsSettingsDialog = true);
    AnnotationsSettingsDialog.show(
      context,
      initialOpacity: widget.opacity,
      initialStrokeWidth: widget.strokeWidth,
      initialCornerSize: widget.cornerSize,
      onSettingsChanged: (newOpacity, newStrokeWidth, newCornerSize) {
        setState(() {
          widget.onOpacityChanged(newOpacity);
          widget.onStrokeWidthChanged(newStrokeWidth);
          widget.onCornerSizeChanged(newCornerSize);
        });
      },
    ).then((_) => setState(() => showAnnotationsSettingsDialog = false));
  }

  @override
  Widget build(BuildContext context) {
    bool annotationDetection = widget.type.toLowerCase().contains('detect');
    bool annotationSegment = widget.type.toLowerCase().contains('segment');
    final bool isCompact = MediaQuery.of(context).size.height < 1024;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: Constants.toolbarWidth,
      decoration: BoxDecoration(
        color: Constants.toolbarBackgroundColor,
        border: const Border(
          right: BorderSide(color: Colors.black, width: 2),
        ),
      ),      
      child: Column(
        children: [
          SizedBox(height: 6),

          // Navigation Button
          ToolbarButton(
            icon: Icon(Icons.near_me_outlined),
            onTap: () => _selectUserAction(UserAction.navigation),
            isActive: widget.selectedAction == UserAction.navigation,
            tooltip: l10n.toolbarNavigation,
          ),

          // Bounding Box Button (conditionally shown)
          if (annotationDetection) ...[
            ToolbarDivider(isCompact: isCompact),
            ToolbarButton(
              icon: Icon(Icons.format_shapes_rounded),
              onTap: () => _selectUserAction(UserAction.bbox_annotation),
              isActive: widget.selectedAction == UserAction.bbox_annotation,
              tooltip: l10n.toolbarBbox,
            ),
          ],

          // Segmentation Button (conditionally shown)
          if (annotationSegment) ...[
            ToolbarDivider(isCompact: isCompact),
            ToolbarButton(
              icon: Icon(Icons.auto_awesome_outlined),
              onTap: () => _selectUserAction(UserAction.sam_annotation),
              isActive: widget.selectedAction == UserAction.sam_annotation,
              tooltip: l10n.toolbarSegmentation,
            ),
            
            // Polygon Annotation Button
            ToolbarDivider(isCompact: isCompact),
            ToolbarButton(
              icon: Icon(Icons.polyline_outlined),
              onTap: () => _selectUserAction(UserAction.polygon_annotation),
              isActive: widget.selectedAction == UserAction.polygon_annotation,
              tooltip: 'Polygon',
            ),
          ],

          // Reset Zoom Button
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.fit_screen_outlined),
            onTap: widget.onResetZoomPressed,
            tooltip: l10n.toolbarResetZoom,
          ),

          // Dataset Grid Toggle
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.apps_outlined),
            onTap: () {
              setState(() => showDatasetGrid = !showDatasetGrid);
              widget.onShowDatasetGridChanged(showDatasetGrid);
            },
            isActive: showDatasetGrid,
            tooltip: l10n.toolbarToggleGrid,
          ),

          // Opacity Settings
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.settings),
            onTap: () => _openAnnotationsSettingsDialog(context),
            isActive: showAnnotationsSettingsDialog,
            tooltip: l10n.toolbarAnnotationSettings,
          ),

          // Annotation Names Toggle
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            onTap: () => widget.onShowAnnotationNames(!widget.showAnnotationNames),
            isActive: !widget.showAnnotationNames,
            tooltip: l10n.toolbarToggleAnnotationNames,
            child: widget.showAnnotationNames
                ? Icon(
                    Icons.text_fields,
                    color: Constants.iconColor,
                    size: Constants.iconSize,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.text_fields,
                        color: Colors.white38,
                        size: Constants.iconSize,
                      ),
                      Transform.rotate(
                        angle: -0.7,
                        child: Container(
                          width: 24,
                          height: 2,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
          ),

          // Rotation Buttons (disabled state)
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.rotate_left_rounded),
            onTap: null,
            tooltip: l10n.toolbarRotateLeft,
            isDisabled: true,
          ),

          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.rotate_right_rounded),
            onTap: null,
            tooltip: l10n.toolbarRotateRight,
            isDisabled: true,
          ),

          const Spacer(),
          ToolbarButton(
            icon: Icon(Icons.help_outline_outlined),
            onTap: () {
              AlertErrorDialog.show(
                context,
                l10n.dialogHelpTitle,
                l10n.dialogHelpContent,
                tips: l10n.dialogHelpTips,
              );
            },
            tooltip: l10n.toolbarHelp,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}