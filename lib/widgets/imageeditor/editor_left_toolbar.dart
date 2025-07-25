import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

import 'editor_action.dart';
import '../imageannotator/toolbar_button.dart';
import '../imageannotator/toolbar_divider.dart';
import '../imageannotator/constants.dart';

class EditorLeftToolbar extends StatefulWidget {
  final String type;
  final EditorAction selectedAction;

  final VoidCallback onResetZoomPressed;
  final ValueChanged<EditorAction> onActionSelected;

  const EditorLeftToolbar({
    super.key,
    required this.type,
    required this.selectedAction,
    required this.onResetZoomPressed,
    required this.onActionSelected,
  });

  @override
  State<EditorLeftToolbar> createState() => _EditorLeftToolbarState();
}

class _EditorLeftToolbarState extends State<EditorLeftToolbar> {

  void _selectUserAction(EditorAction action) {
    widget.onActionSelected(action);
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: () => _selectUserAction(EditorAction.navigation),
            isActive: widget.selectedAction == EditorAction.navigation,
            tooltip: l10n.toolbarNavigation,
          ),

          // Reset Zoom Button
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.fit_screen_outlined),
            onTap: widget.onResetZoomPressed,
            tooltip: l10n.toolbarResetZoom,
          ),


          // Crop Button
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.crop),
            onTap: () => _selectUserAction(EditorAction.crop),
            isActive: widget.selectedAction == EditorAction.crop,
            tooltip: 'Crop Image',
          ),

          // Rotation Buttons
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.rotate_left_rounded),
            onTap: () => _selectUserAction(EditorAction.rotate_left),
            isActive: widget.selectedAction == EditorAction.rotate_left,
            tooltip: l10n.toolbarRotateLeft,
          ),

          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.rotate_right_rounded),
            onTap: () => _selectUserAction(EditorAction.rotate_right),
            isActive: widget.selectedAction == EditorAction.rotate_right,
            tooltip: l10n.toolbarRotateRight,
          ),
          
          // Flip Buttons
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.flip),
            onTap: () => _selectUserAction(EditorAction.flip_horizontal),
            isActive: widget.selectedAction == EditorAction.flip_horizontal,
            tooltip: 'Flip Horizontal',
          ),
          
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.flip_camera_android),
            onTap: () => _selectUserAction(EditorAction.flip_vertical),
            isActive: widget.selectedAction == EditorAction.flip_vertical,
            tooltip: 'Flip Vertical',
          ),
          
          // Brightness and Contrast
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.brightness_6),
            onTap: () => _selectUserAction(EditorAction.brightness),
            isActive: widget.selectedAction == EditorAction.brightness,
            tooltip: 'Adjust Brightness',
          ),
          
          ToolbarDivider(isCompact: isCompact),
          ToolbarButton(
            icon: Icon(Icons.contrast),
            onTap: () => _selectUserAction(EditorAction.contrast),
            isActive: widget.selectedAction == EditorAction.contrast,
            tooltip: 'Adjust Contrast',
          ),
        ],
      ),
    );
  }
}