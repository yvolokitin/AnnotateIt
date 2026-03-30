import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class DatasetTaskTypeGrid extends StatelessWidget {
  final String? selectedTaskType;
  final ValueChanged<String> onTaskSelected;
  final List<Map<String, String>> tasks;

  const DatasetTaskTypeGrid({
    super.key,
    this.selectedTaskType,
    required this.onTaskSelected,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final rawCols = w > 1200 ? 3 : w > 600 ? 2 : 1;
        final crossAxisCount = rawCols.clamp(1, tasks.length);
        const double spacing = 14;

        final rows = (tasks.length / crossAxisCount).ceil();
        final cardWidth =
            (w - (crossAxisCount - 1) * spacing) / crossAxisCount;
        final fitHeight = (h - (rows - 1) * spacing) / rows;

        // If cards fit comfortably, fill the space; otherwise allow scroll.
        const double minCardH = 190.0;
        final fitsOnScreen = fitHeight >= minCardH;
        final cardHeight = fitsOnScreen ? fitHeight : minCardH;
        final childAR = cardWidth / cardHeight;

        return GridView.builder(
          physics: fitsOnScreen
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAR,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _TaskCard(
              task: task,
              isSelected: selectedTaskType == task['value'],
              onTap: () => onTaskSelected(task['value']!),
            );
          },
        );
      },
    );
  }
}

class _TaskCard extends StatefulWidget {
  final Map<String, String> task;
  final bool isSelected;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hovering ? AppColors.darkCardHover : AppColors.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accent
                  : _hovering
                      ? Colors.white.withAlpha(51)
                      : Colors.white.withAlpha(15),
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: AppColors.accent.withAlpha(38),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              if (_hovering && !widget.isSelected)
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image area — takes ~60% of card, cropped to fill
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.task['image']!,
                        fit: BoxFit.cover,
                      ),
                      if (widget.isSelected)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.accent.withAlpha(0),
                                AppColors.accent.withAlpha(38),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Text area — takes ~40%, adapts to available space
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              widget.isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 18,
                              color: widget.isSelected
                                  ? AppColors.accent
                                  : Colors.white38,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.task['title']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            widget.task['description']!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              height: 1.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
