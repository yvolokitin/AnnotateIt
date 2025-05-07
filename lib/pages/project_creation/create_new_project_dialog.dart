import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../models/label.dart';

import '../../widgets/edit_labels_dialog.dart';
import 'project_tabs/detection_tab.dart';
import 'project_tabs/segmentation_tab.dart';
import 'project_tabs/classification_tab.dart';
// import 'project_tabs/anomaly_tab.dart';
// import 'project_tabs/chained_tasks_tab.dart';

class CreateNewProjectDialog extends StatefulWidget {
  final String? initialName;
  final String? initialType;
  final List<Label>? initialLabels;

  const CreateNewProjectDialog({
    super.key,
    this.initialName,
    this.initialType,
    this.initialLabels,
  });

  @override
  CreateNewProjectDialogState createState() => CreateNewProjectDialogState();
}

class CreateNewProjectDialogState extends State<CreateNewProjectDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late TabController _tabController;
  String _selectedTaskType = "Detection bounding box";

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _selectedTaskType = widget.initialType ?? 'Detection bounding box';
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 1600;
        final isTablet = constraints.maxWidth >= 800 && constraints.maxWidth < 1600;
        // final isMobile = constraints.maxWidth < 800;

        final dialogPadding = isLargeScreen
            ? const EdgeInsets.all(60)
            : isTablet
                ? const EdgeInsets.all(24)
                : const EdgeInsets.all(12);

        final dialogWidth = constraints.maxWidth * (isLargeScreen ? 0.9 : 1.0);
        final dialogHeight = constraints.maxHeight * (isLargeScreen ? 0.9 : 1.0);

        final content = _buildDialogContent();

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            // padding: dialogPadding,
            child: Padding(
              padding: dialogPadding,
              child: content,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("New Project Creation", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    Text("Please, enter your new project name and select Project type", style: TextStyle(fontSize: 22, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Project Name", filled: true, fillColor: Colors.grey[850]),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 20),
              ),
              const SizedBox(height: 26),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.red,
                indicatorWeight: 3.0,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontSize: 24),
                unselectedLabelStyle: const TextStyle(fontSize: 24),
                tabs: const [
                  Tab(text: "Detection"),
                  Tab(text: "Classification"),
                  Tab(text: "Segmentation"),
                  // Tab(text: "Anomaly"),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    DetectionTab(selectedTaskType: _selectedTaskType, onSelected: _setSelectedTask),
                    ClassificationTab(selectedTaskType: _selectedTaskType, onSelected: _setSelectedTask),
                    SegmentationTab(selectedTaskType: _selectedTaskType, onSelected: _setSelectedTask),
                    // AnomalyTab(selectedTaskType: _selectedTaskType, onSelected: _setSelectedTask),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("<- Back", style: TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await showDialog<String>(
                              context: context,
                              builder: (context) => EditLabelsDialog(
                                project: Project(
                                  id: null,
                                  name: _nameController.text,
                                  description: '',
                                  type: _selectedTaskType,
                                  icon: 'assets/images/default_project_image.svg',
                                  creationDate: DateTime.now(),
                                  lastUpdated: DateTime.now(),
                                  defaultDatasetId: '',
                                  ownerId: 1,
                                ),
                                onLabelsUpdated: () {},
                                isFromCreationFlow: true,
                                initialLabels: widget.initialLabels,
                              ),
                            );
                            if (!mounted) return;
                            Navigator.pop(context, result);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Next -> ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  void _setSelectedTask(String task) {
    setState(() => _selectedTaskType = task);
  }
}
