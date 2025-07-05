import 'package:flutter/material.dart';
import '../../models/project.dart';
import "../../utils/date_utils.dart";

import 'labels_list.dart';
import 'project_icon.dart';

class ProjectTile extends StatefulWidget {
  final Project project;
  final VoidCallback onMorePressed; // Callback for more options
  final VoidCallback? onTap; // Callback on update list of projects

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double thumbnailHeight = screenWidth > 1100 ? 180 : screenWidth > 860 ? 160 : 140;
    final double thumbnailWidth = screenWidth > 1100 ? 350 : screenWidth > 860 ? 280 : 180;
    final double nameFontSize = screenWidth > 1100 ? 24.0 : screenWidth > 860 ? 20.0 : 18.0;
    final double typeFontSize = screenWidth > 1100 ? 22.0 : screenWidth > 860 ? 18.0 : 16.0;
    final double dateFontSize = screenWidth > 1100 ? 18.0 : screenWidth > 860 ? 16.0 : 14.0;
    final double verticalSpacing = screenWidth > 1100 ? 6.0 : screenWidth > 860 ? 4.0 : 2.0;
    final double labelFontSize = screenWidth > 1100 ? 18.0 : screenWidth > 860 ? 16.0 : 14.0;
  
    return MouseRegion(
      // Change cursor to hand when hovering
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true), // Hover start
      onExit: (_) => setState(() => _isHovered = false), // Hover end

      child: GestureDetector(
        // onTap: widget.onTap ?? () => print("Project '${widget.project.name}' clicked, but no onTap handler provided"),
        onTap: widget.onTap,
        child: Card(
          color: Colors.grey.shade800,
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          elevation: _isHovered ? 8 : 3,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: _isHovered ? Colors.red : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail (Left Side)
                if (screenWidth >= 650)
                  Container(
                    width: thumbnailWidth, // 350,
                    height: thumbnailHeight, // 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[850], // Background color
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: ProjectIcon(iconPath: widget.project.icon),
                    ),
                  ),
                  SizedBox(width: 12),

                // Project Details: Title @ Type, Updated and creation Dates, Labels
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Name (line 1)
                        Text(
                          widget.project.name,
                          style: TextStyle(
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Project Type (line 2)
                        Text(
                          "@ ${widget.project.type}",
                          style: TextStyle(
                            fontSize: typeFontSize,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: verticalSpacing),
                        // Updated / Created (line 3)
                        Text(
                          "Updated: ${formatDate(widget.project.lastUpdated)} / Created: ${formatDate(widget.project.creationDate)}",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: dateFontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Divider(
                          color: Colors.grey,
                          thickness: 2,
                          height: 32,
                        ),

                        // to show Labels Section with colored tags in
                        LabelList(
                          labels: widget.project.labels ?? [],
                          projectName: widget.project.name,
                          iconPath: widget.project.icon,
                          fontLabelSize: labelFontSize,
                        ),
                      ],
                    ), // Column
                  ), // Padding
                ),

                // Right Side (Progress Indicator + More Options)
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
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
