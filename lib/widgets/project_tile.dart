import 'package:flutter/material.dart';
import '../models/project.dart';
import "../utils/date_utils.dart";

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
    return MouseRegion(
      // Change cursor to hand when hovering
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true), // Hover start
      onExit: (_) => setState(() => _isHovered = false), // Hover end

      child: GestureDetector(
        onTap: widget.onTap ??
          () => print("Project '${widget.project.name}' clicked, but no onTap handler provided"),

        child: Card(
          color: Colors.grey.shade800, // Dark theme background
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          elevation: _isHovered ? 8 : 3, // Add shadow on hover
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: _isHovered ? Colors.red : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.0), // ensure image will be 100% in height and weight
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail (Left Side)
                Container(
                  width: 350,
                  height: 180,
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
                        // Project Name & Type
/*                        
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.project.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: " @ ${widget.project.type}",
                                style: TextStyle(color: Colors.white70, fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),

                        // Last update
                        Text(
                          "Updated: ${formatDate(widget.project.lastUpdated)} / Created: ${formatDate(widget.project.creationDate)}",
                          style: TextStyle(color: Colors.white60, fontSize: 18),
                        ),
                        SizedBox(height: 8),
*/

// Project Name (line 1)
Text(
  widget.project.name,
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),

// Project Type (line 2)
Text(
  "@ ${widget.project.type}",
  style: const TextStyle(
    fontSize: 22,
    color: Colors.white70,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),

const SizedBox(height: 4),

// Updated / Created (line 3)
Text(
  "Updated: ${formatDate(widget.project.lastUpdated)} / Created: ${formatDate(widget.project.creationDate)}",
  style: const TextStyle(
    color: Colors.white60,
    fontSize: 18,
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
                        LabelList(labels: widget.project.labels ?? []),
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
