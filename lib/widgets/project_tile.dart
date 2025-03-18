import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';

import '../models/project.dart';

class ProjectTile extends StatelessWidget {
  final Project project;
  final VoidCallback onMorePressed; // Callback for more options

  const ProjectTile({required this.project, required this.onMorePressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800, // Dark theme background
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(0.0), // ensure image will be 100% in height and weight
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail o(Left Side)
            Container(
              width: 350,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[900], // Background color
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/default_project_image.svg',
                  width: 40, // Adjust size
                  height: 40,
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12),

            // 📌 Project Details (Title, Type, Date, Labels)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Name & Type
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: project.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: " @ ${project.type}",
                          style: TextStyle(color: Colors.white70, fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),

                  // Creation Date
                  Text(
                    "Created: ${_formatDate(project.creationDate)}",
                    style: TextStyle(color: Colors.white60, fontSize: 18),
                  ),
                  SizedBox(height: 8),

                  // 📌 Labels Section (Colored Tags)
                  Wrap(
                    spacing: 8,
                    children: project.labels.take(3).map((label) {
                      return _buildLabel(label);
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 📌 Right Side (Progress Indicator + More Options)
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: onMorePressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Label Builder with Different Colors
  Widget _buildLabel(String label) {
    final Map<String, Color> labelColors = {
      "blue": Colors.blue,
      "yellow": Colors.yellow,
      "red": Colors.red,
      "Normal": Colors.green,
      "Anomalous": Colors.red,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: labelColors[label] ?? Colors.white24, // Default color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  // 📅 Date Formatter
  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year} | ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  // 🔹 Convert month number to name
  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}
