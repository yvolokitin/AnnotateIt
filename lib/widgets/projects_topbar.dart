import 'package:flutter/material.dart';

class ProjectsTopBar extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final Function(String) onSortSelected;
  final VoidCallback onCreateProject;

  const ProjectsTopBar({
    super.key,
    required this.onSearchPressed,
    required this.onSortSelected,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Search Icon
          IconButton(
            icon: Icon(Icons.search, color: Colors.white70),
            onPressed: onSearchPressed,
          ),
             
          SizedBox(width: 20),
          // Sort Icon
          PopupMenuButton<String>(
            icon: Icon(Icons.swap_vert, color: Colors.white70),
            onSelected: (value) => onSortSelected(value),
            itemBuilder: (context) => [
              PopupMenuItem(value: "Last updated", child: Text("Last updated")),
              PopupMenuItem(value: "Newest-Oldest", child: Text("Newest-Oldest")),
              PopupMenuItem(value: "Oldest-Newest", child: Text("Oldest-Newest")),
              PopupMenuItem(value: "Project Type", child: Text("Project Type")),
              PopupMenuItem(value: "A-Z", child: Text("A-Z")),
              PopupMenuItem(value: "Z-A", child: Text("Z-A")),
            ],
          ),

          SizedBox(width: 20),
          Divider(color: Colors.white70),
          SizedBox(width: 20),

          // Create New Project Button
          ElevatedButton(
            onPressed: onCreateProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Row(
              children: [
                Text("Create new project", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                // Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),

          SizedBox(width: 20),
        ],
      ),
    );
  }

  void _showSortMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(200, 100, 0, 0),
      items: [
        PopupMenuItem(value: "A-Z", child: Text("A-Z")),
        PopupMenuItem(value: "Z-A", child: Text("Z-A")),
        PopupMenuItem(value: "Newest-Oldest", child: Text("Newest-Oldest")),
        PopupMenuItem(value: "Oldest-Newest", child: Text("Oldest-Newest")),
        PopupMenuItem(value: "Project Type", child: Text("Project Type")),
      ],
    ).then((value) {
      if (value != null) {
        onSortSelected(value);
      }
    });
  }
}
