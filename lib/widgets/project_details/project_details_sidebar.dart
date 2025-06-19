import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/date_utils.dart';
import '../../models/project.dart';
import '../dialogs/edit_project_name_dialog.dart';

class ProjectDetailsSidebar extends StatefulWidget {
  final Project project;
  final int selectedIndex;
  final void Function(int index) onItemSelected;

  const ProjectDetailsSidebar({
    super.key,
    required this.project,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<ProjectDetailsSidebar> createState() => _ProjectDetailsSidebarState();
}

class _ProjectDetailsSidebarState extends State<ProjectDetailsSidebar> {
  bool _hovering = false;
  late String _projectName;

  @override
  void initState() {
    super.initState();
    _projectName = widget.project.name;
  }

  void _editProjectName() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => EditProjectNameDialog(name: _projectName),
    );

    if (newName != null && newName != _projectName) {
      setState(() {
        _projectName = newName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSvg = widget.project.icon.toLowerCase().endsWith('.svg');
    return Container(
      padding: const EdgeInsets.all(25.0),
      color: Colors.grey[850],
      height: 400, // increased to fit all with spacing
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Name with Edit Icon
          MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            cursor: SystemMouseCursors.click,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                const SizedBox(height: 20),

                Tooltip(
                  message: _projectName,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(right: 32), // reserve space for icon
                    child: Text(
                      _projectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _hovering ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    iconSize: 20,
                    tooltip: 'Edit project name',
                    onPressed: _editProjectName,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          // Project Icon
          isSvg
              ? SvgPicture.asset(
                widget.project.icon,
                height: 140,
                fit: BoxFit.cover,
                // color: Colors.white,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              )
              : Image.file(
                  File(widget.project.icon),
                  height: 140,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 80, color: Colors.white54);
                  },
                ),

          const SizedBox(height: 15),
          Text(
            "Type: ${widget.project.type}", // Project Type
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 22,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 15),
          Text(
            "Created at ${formatDate(widget.project.creationDate)}",
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.normal,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
