import 'dart:io';
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

import '../dialogs/annotations_settings_dialog.dart';
import '../dialogs/sam_model_selector_dialog.dart';
import '../../session/user_session.dart';

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
  final bool isProcessingMlKit;
  final bool isProcessingSAM;

  /// Key of selected SAM model: 'mobile' or 'sam2_hiera_base_plus'
  final String selectedSamModelKey;
  final ValueChanged<String> onSamModelChanged;

  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<double> onStrokeWidthChanged;
  final ValueChanged<double> onCornerSizeChanged;
  final VoidCallback onResetZoomPressed;
  final ValueChanged<bool> onShowDatasetGridChanged;
  final ValueChanged<UserAction> onActionSelected;
  final ValueChanged<bool> onShowAnnotationNames;
  final VoidCallback onSwitchToEditor;

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
    required this.selectedSamModelKey,
    required this.onSamModelChanged,
    required this.onSwitchToEditor,
    this.isProcessingMlKit = false,
    this.isProcessingSAM = false,
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

  Future<void> _openSamModelSelector(BuildContext context) async {
    final isInit = UserSession.instance.isInitialized;
    final initialRemember = isInit ? UserSession.instance.getUser().samRememberChoice : false;

    // If user chose to remember, skip dialog and use preferred model
    if (isInit && initialRemember) {
      final preferredKey = UserSession.instance.getUser().preferredSamModelKey;
      if (preferredKey != widget.selectedSamModelKey) {
        widget.onSamModelChanged(preferredKey);
      }
      _selectUserAction(UserAction.sam_annotation);
      return;
    }

    final result = await SamModelSelectorDialog.show(
      context,
      initialSelectedKey: widget.selectedSamModelKey,
      initialRemember: initialRemember,
    );

    if (result != null) {
      if (result.modelKey != widget.selectedSamModelKey) {
        widget.onSamModelChanged(result.modelKey);
      }

      // Persist user preference if requested
      if (isInit) {
        await UserSession.instance.setSamRememberChoice(result.remember);
        if (result.remember) {
          await UserSession.instance.setPreferredSamModelKey(result.modelKey);
        }
      }

      // After choosing a model, activate the SAM tool for immediate use
      _selectUserAction(UserAction.sam_annotation);
    }
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

          // Polygon Annotation Button (only for segmentation)
          if (annotationSegment) ...[
            ToolbarDivider(isCompact: isCompact),
            ToolbarButton(
              icon: Icon(Icons.polyline_outlined),
              onTap: () => _selectUserAction(UserAction.polygon_annotation),
              isActive: widget.selectedAction == UserAction.polygon_annotation,
              tooltip: l10n.toolbarPolygon,
            ),
          ],

          // SAM Button (shown for segmentation and detection projects)
          if (annotationSegment || annotationDetection) ...[
            ToolbarDivider(isCompact: isCompact),
            ToolbarButton(
              icon: Icon(Icons.auto_awesome_outlined),
              onTap: widget.isProcessingSAM
                ? null
                : () async => await _openSamModelSelector(context),
              isActive: widget.selectedAction == UserAction.sam_annotation,
              tooltip: '${l10n.toolbarSAM} • ${widget.selectedSamModelKey == 'mobile' ? 'SAM mobile' : 'SAM2 Hiera-Base+'}',
            ),
          ],

          // ML Kit Image Labeling Button - only shown on Android/iOS
          // This is the AI annotation tool for mobile platforms
          if (Platform.isAndroid || Platform.isIOS) ...[
            ToolbarDivider(isCompact: isCompact),
            ToolbarButton(
              // icon: Icon(Icons.auto_awesome),
              icon: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 12,
                child: Text(
                  'ML',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'CascadiaCode',
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: widget.isProcessingMlKit
                  ? null // Disable button while processing
                  : () => _selectUserAction(UserAction.ml_kit_labeling),
              isActive: widget.selectedAction == UserAction.ml_kit_labeling,
              tooltip: 'Google ML Kit Image Labeling',
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
                    color: Colors.white70,
                    size: 28,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.text_fields,
                        color: Colors.white38,
                        size: 28,
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

          const Spacer(),
          ToolbarButton(
            icon: Icon(Icons.edit_outlined),
            onTap: widget.onSwitchToEditor,
            tooltip: 'Switch to Image Editor',
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}