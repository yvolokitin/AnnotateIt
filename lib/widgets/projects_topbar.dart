import 'package:flutter/material.dart';

class ProjectsTopBar extends StatelessWidget {
  final bool sortDetection, sortClassification, sortSegmentation;

  final VoidCallback onSearchPressed;
  final Function(String) onSortSelected;
  final VoidCallback onCreateProject;
  final VoidCallback onCreateFromDataset;
  final VoidCallback onCreateFromExport;

  final VoidCallback onSortDetection;
  final VoidCallback onSortClassification;
  final VoidCallback onSortSegmentation;

  const ProjectsTopBar({
    super.key,
    required this.sortDetection,
    required this.sortClassification,
    required this.sortSegmentation,
    required this.onSearchPressed,
    required this.onSortSelected,
    required this.onCreateProject,
    required this.onCreateFromDataset,
    required this.onCreateFromExport,

    required this.onSortDetection,
    required this.onSortClassification,
    required this.onSortSegmentation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Row(
        children: [
          const SizedBox(width: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSortDetection,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: sortDetection ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.crop_free_rounded, // panorama_wide_angle_rounded,
                  color: sortDetection ? Colors.white : Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSortClassification,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: sortClassification ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: sortClassification ? Colors.white : Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSortSegmentation,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: sortSegmentation ? Colors.grey[850] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.extension_outlined,
                  color: sortSegmentation ? Colors.white : Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ),

          const Spacer(),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
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
                    onCreateFromDataset();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Text("Create from dataset", style: TextStyle(color: Colors.white, fontSize: 22)),
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
