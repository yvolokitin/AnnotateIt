import 'package:flutter/material.dart';
import '../../utils/platform_utils.dart';
import '../../utils/theme.dart';
import '../../models/project.dart';
import "../../utils/date_utils.dart";

import 'labels_list.dart';
import 'project_icon.dart';

class ProjectTile extends StatefulWidget {
  final Project project;
  final VoidCallback onMorePressed;
  final VoidCallback? onTap;

  ProjectTile({
    super.key,
    required this.project,
    required this.onMorePressed,
    this.onTap,
  });

  @override
  ProjectTileState createState() => ProjectTileState();
}

class ProjectTileState extends State<ProjectTile> {
  bool _isHovered = false;
  bool _isMouseDown = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double thumbnailHeight = (screenWidth > 1100) ? 180 : (screenWidth > 860) ? 160 : (screenWidth > 650) ? 140 : 110;
    final double thumbnailWidth = (screenWidth > 1100) ? 350 : (screenWidth > 860) ? 280 : (screenWidth > 650) ? 180 : 140;

    final double nameFontSize = PlatformUtils.isIOS
        ? (screenWidth > 1100 ? 22.0 : screenWidth > 860 ? 18.0 : 14.0)
        : (screenWidth > 1100 ? 22.0 : screenWidth > 860 ? 19.0 : 16.0);
    final double typeFontSize = PlatformUtils.isIOS
        ? (screenWidth > 1100 ? 20.0 : screenWidth > 860 ? 16.0 : 14.0)
        : (screenWidth > 1100 ? 18.0 : screenWidth > 860 ? 16.0 : 14.0);
    final double dateFontSize = PlatformUtils.isIOS
        ? (screenWidth > 1100 ? 16.0 : screenWidth > 860 ? 14.0 : 12.0)
        : (screenWidth > 1100 ? 15.0 : screenWidth > 860 ? 14.0 : 12.0);
    final double verticalSpacing = PlatformUtils.isIOS
        ? (screenWidth > 1100 ? 5.0 : screenWidth > 860 ? 3.0 : 2.0)
        : (screenWidth > 1100 ? 6.0 : screenWidth > 860 ? 4.0 : 2.0);
    final double labelFontSize = PlatformUtils.isIOS
        ? (screenWidth > 1100 ? 16.0 : screenWidth > 860 ? 14.0 : 12.0)
        : (screenWidth > 1100 ? 16.0 : screenWidth > 860 ? 14.0 : 12.0);

    return MouseRegion(
      cursor: _isMouseDown
          ? SystemMouseCursors.grabbing
          : (_isHovered ? SystemMouseCursors.grab : SystemMouseCursors.basic),
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _isMouseDown = true),
        onPointerUp: (_) => setState(() => _isMouseDown = false),
        onPointerCancel: (_) => setState(() => _isMouseDown = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(
              horizontal: (screenWidth > 1200) ? 24 : 12,
              vertical: (screenWidth > 1200) ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.darkCardHover : AppColors.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isHovered
                    ? AppColors.accent.withOpacity(0.5)
                    : Colors.white.withOpacity(0.06),
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: thumbnailWidth,
                  height: thumbnailHeight,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                    child: ProjectIcon(iconPath: widget.project.icon),
                  ),
                ),
                SizedBox(width: screenWidth > 650 ? 14 : 8),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth > 650 ? 12.0 : 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.name,
                          style: TextStyle(
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 2),
                        Text(
                          widget.project.type,
                          style: TextStyle(
                            fontSize: typeFontSize,
                            color: AppColors.accentOrange.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: verticalSpacing),
                        if (screenWidth < 650) ...[
                          Text(
                            "Updated ${formatDate(widget.project.lastUpdated)}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: dateFontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Created ${formatDate(widget.project.creationDate)}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: dateFontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        if (screenWidth >= 650) ...[
                          Text(
                            "Updated ${formatDate(widget.project.lastUpdated)}  ·  Created ${formatDate(widget.project.creationDate)}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: dateFontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          LabelList(
                            labels: widget.project.labels ?? [],
                            projectName: widget.project.name,
                            iconPath: widget.project.icon,
                            fontLabelSize: labelFontSize,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      onPressed: widget.onMorePressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
