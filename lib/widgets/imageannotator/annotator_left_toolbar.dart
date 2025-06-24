import 'package:flutter/material.dart';
import 'user_action.dart';

class AnnotatorLeftToolbar extends StatefulWidget {
  final String type;
  final double opacity;
  final UserAction selectedAction;
  final bool showAnnotationNames;

  final ValueChanged<double> onOpacityChanged;
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
  });

  @override
  State<AnnotatorLeftToolbar> createState() => _AnnotatorLeftToolbarState();
}

class _AnnotatorLeftToolbarState extends State<AnnotatorLeftToolbar> {
  String userAction = 'navigation';
  bool showOpacityDialog = false;
  bool showDatasetGrid = false;
  bool _isHovered = false;

  void _selectUserAction(UserAction action) {
    setState(() => userAction = action.name);
    widget.onActionSelected(action);
  }

  @override
  Widget build(BuildContext context) {
    bool annotationDetection = widget.type.toLowerCase().contains('detect');
    bool annotationSegment = widget.type.toLowerCase().contains('segment');

    final bool isCompact = MediaQuery.of(context).size.height < 1024;

    return Container(
      width: 62,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(
          right: BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),      
      child: Column(
        children: [
          SizedBox(height: isCompact ? 40 : 80),

          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _selectUserAction(UserAction.navigation),
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: (userAction == 'navigation') ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.near_me_outlined, // pinch_outlined,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
            ),
          ),

          if (annotationDetection) ...[
            Divider(color: Colors.white30, height: isCompact ? 15 : 30),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _selectUserAction(UserAction.bbox_annotation),
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: (userAction == 'bbox_annotation') ? Colors.grey[850] : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.format_shapes_rounded,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],

          if (annotationSegment) ...[
            Divider(color: Colors.white30, height: isCompact ? 15 : 30),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _selectUserAction(UserAction.sam_annotation),
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: (userAction == 'sam_annotation') ? Colors.grey[850] : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],

          Divider(color: Colors.white30, height: isCompact ? 15 : 30),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
              onTap: widget.onResetZoomPressed,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _isHovered ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.fit_screen_outlined,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
            ),
          ),

          Divider(color: Colors.white30, height: isCompact ? 15 : 30),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() => showDatasetGrid = !showDatasetGrid);
                widget.onShowDatasetGridChanged(showDatasetGrid);
              },
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: showDatasetGrid ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.apps_outlined,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
            ),
          ),

          Divider(color: Colors.white30, height: isCompact ? 15 : 30),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showOpacityDialog(context),
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: showOpacityDialog ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
            ),
          ),

          Divider(color: Colors.white30, height: isCompact ? 15 : 30),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                widget.onShowAnnotationNames(!widget.showAnnotationNames);
              },
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: (!widget.showAnnotationNames) ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: widget.showAnnotationNames
                  ? const Icon(
                    Icons.text_fields,
                    color: Colors.white70,
                    size: 28,
                  )
                  : Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
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
            ),
          ),

          Divider(color: Colors.white30, height: isCompact ? 15 : 30),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: showOpacityDialog ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.rotate_left_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
            ),
          ),

          Divider(color: Colors.white30, height: isCompact ? 15 : 30),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: showOpacityDialog ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.rotate_right_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
            ),
          ),

          const Spacer(),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent, // showDatasetGrid ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.help_outline_outlined,
                  color: Colors.white60,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showOpacityDialog(BuildContext context) {
    setState(() => showOpacityDialog = true);
    double tempOpacity = widget.opacity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Annotation Fill Opacity'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: tempOpacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(tempOpacity * 100).round()}%',
                    onChanged: (value) => setState(() => tempOpacity = value),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onOpacityChanged(tempOpacity);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    ).then((_) => setState(() => showOpacityDialog = false));
  }
}
