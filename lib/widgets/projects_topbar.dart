import 'package:flutter/material.dart';

class ProjectsTopBar extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final Function(String) onSortSelected;
  final VoidCallback onCreateProject;
  final VoidCallback onCreateFromDataset;
  final VoidCallback onCreateFromExport;

  const ProjectsTopBar({
    super.key,
    required this.onSearchPressed,
    required this.onSortSelected,
    required this.onCreateProject,
    required this.onCreateFromDataset,
    required this.onCreateFromExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: onSearchPressed,
          ),

          const SizedBox(width: 20),

          PopupMenuButton<String>(
            icon: const Icon(Icons.swap_vert, color: Colors.white70),
            onSelected: onSortSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(value: "Last updated", child: Text("Last updated")),
              PopupMenuItem(value: "Newest-Oldest", child: Text("Newest-Oldest")),
              PopupMenuItem(value: "Oldest-Newest", child: Text("Oldest-Newest")),
              PopupMenuItem(value: "Project Type", child: Text("Project Type")),
              PopupMenuItem(value: "A-Z", child: Text("A-Z")),
              PopupMenuItem(value: "Z-A", child: Text("Z-A")),
            ],
          ),

          const SizedBox(width: 20),
          // const VerticalDivider(color: Colors.white70),
          // const SizedBox(width: 20),

          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  // color: Colors.black.withOpacity(0.3),
                  color: Colors.black.withAlpha((0.3 * 255).toInt()),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onCreateProject,
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: const Text(
                      "Create new project",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                PopupMenuButton<int>(
                  color: const Color(0xFF2E2E2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 0) onCreateFromDataset();
                    if (value == 1) onCreateFromExport();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Text("Create from dataset", style: TextStyle(color: Colors.white, fontSize: 22)),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text("Create from exported project", style: TextStyle(color: Colors.white, fontSize: 22)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
