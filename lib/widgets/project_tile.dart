import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../pages/project_details_screen.dart';
import 'labels_list.dart';

class ProjectTile extends StatefulWidget {
  final Project project;
  final VoidCallback onMorePressed; // Callback for more options

  ProjectTile({
    required this.project,
    required this.onMorePressed,
    super.key,
  });

  @override
  _ProjectTileState createState() => _ProjectTileState();
}

class _ProjectTileState extends State<ProjectTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Change cursor to hand when hovering
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true), // Hover start
      onExit: (_) => setState(() => _isHovered = false), // Hover end

      child: GestureDetector(
        onTap: () {
          print("Project '${widget.project.name}' clicked!");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(widget.project),
            ),
          );
        },
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
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/default_project_image.svg',
                      width: 45, // Adjust size
                      height: 45,
                      fit: BoxFit.cover,
                      color: Colors.white,
                    ),
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
                          "Updated: ${_formatDate(widget.project.lastUpdated)} / Created: ${_formatDate(widget.project.creationDate)}",
                          style: TextStyle(color: Colors.white60, fontSize: 18),
                        ),
                        SizedBox(height: 8),

                        Divider(
                          color: Colors.grey,
                          thickness: 2,
                          height: 32,
                        ),

                        // Labels Section (Colored Tags)
                        LabelList(
                          labels: widget.project.labels.toList(),
                          labelColors: widget.project.labelColors.toList(),
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

  // Date Formatter
  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year} | ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  // Convert month number to name
  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}
