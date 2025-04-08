import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/label.dart';

import 'edit_labels_dialog.dart';
import 'create_project_dialog_task.dart';

class CreateProjectDialog extends StatefulWidget {
  // both parameters are optional and needed only if user pressed back from Label creation step
  final String? initialName;
  final String? initialType;
  final List<Label>? initialLabels;

  const CreateProjectDialog({
    super.key,
    this.initialName,
    this.initialType,
    this.initialLabels,
  });

  @override
  CreateProjectDialogState createState() => CreateProjectDialogState();
}

class CreateProjectDialogState extends State<CreateProjectDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late TabController _tabController;
  String _selectedTaskType = "Detection bounding box"; // Default selection

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.initialName ?? '';
    _selectedTaskType = widget.initialType ?? 'Detection bounding box';
  
      // 5 tabs for project types: Detection, Segmentation, Classification, Anomaly, Chained tasks
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dialogWidth, dialogHeight;
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 1600;
    final dialogPadding = isLargeScreen ? EdgeInsets.all(60) : EdgeInsets.all(12);

    if (isLargeScreen)  {
      dialogWidth = MediaQuery.of(context).size.width * 0.9;
      dialogHeight = MediaQuery.of(context).size.height * 0.9;
    } else {
      dialogWidth = MediaQuery.of(context).size.width;
      dialogHeight = MediaQuery.of(context).size.height;
    }

    return Dialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📌 Title Section
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("New Project Creation", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text("Please, enter your new project name and select Project type", style: TextStyle(fontSize: 22, color: Colors.white70)),
                ],
              ),
            ),
            SizedBox(height: 26),

            // Project Name Input Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Project Name", filled: true, fillColor: Colors.grey[850]),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 20),
            ),
            SizedBox(height: 26),

            // Tabs for Project Types
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.red,
              indicatorWeight: 3.0,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontSize: 24),
              unselectedLabelStyle: const TextStyle(fontSize: 24),
              tabs: [
                Tab(text: "Detection"),
                Tab(text: "Segmentation"),
                Tab(text: "Classification"),
                Tab(text: "Anomaly"),
                Tab(text: "Chained tasks"),
              ],
            ),
            SizedBox(height: 16),

            // 📌 Scrollable Content Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetectionTaskTypeSelection(),
                  _buildSegmentationTaskTypeSelection(),
                  _buildClassificationTaskTypeSelection(),
                  _buildAnomalyTaskTypeSelection(),
                  _buildChainedTasksSelection(),
                ],
              ),
            ),

            // 📌 Bottom Navigation Buttons
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("<- Back", style: TextStyle(color: Colors.white70)),
                      ),
                      SizedBox(width: 8),
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
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Next -> ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionTaskTypeSelection() {
    return TaskTypeGrid(
      selectedTaskType: _selectedTaskType,
      onTaskSelected: (value) => setState(() => _selectedTaskType = value),
      tasks: [
        {
          'title': 'Detection bounding box',
          'description': 'Draw a rectangle around an object in an image.',
          'image': 'assets/images/detection_bounding_box.jpg',
        },
        {
          'title': 'Detection oriented',
          'description': 'Draw and enclose an object within a minimal rectangle.',
          'image': 'assets/images/detection_oriented.jpg',
        },
      ],
    );
  }

  Widget _buildSegmentationTaskTypeSelection() {
    return TaskTypeGrid(
      selectedTaskType: _selectedTaskType,
      onTaskSelected: (value) => setState(() => _selectedTaskType = value),
      tasks: [
        {
          'title': 'Instance Segmentation',
          'description': 'Detect and distinguish each individual object based on its unique features.',
          'image': 'assets/images/instance_segmentation.jpg',
        },
        {
          'title': 'Semantic Segmentation',
          'description': 'Detect and classify all similar objects as a single entity.',
          'image': 'assets/images/semantic_segmentation.jpg',
        },
      ]
    );
  }

  Widget _buildClassificationTaskTypeSelection() {
    return TaskTypeGrid(
      selectedTaskType: _selectedTaskType,
      onTaskSelected: (value) => setState(() => _selectedTaskType = value),
      tasks: [
        {
          'title': 'Classification single label',
          'description': 'Assign a label out of mutually exclusive labels.',
          'image': 'assets/images/classification_single.png',
        },
        {
          'title': 'Classification multi label',
          'description': 'Assign label(s) out of non-mutually exclusive labels.',
          'image': 'assets/images/classification_multi.png',
        },
        {
          'title': 'Classification hierarchical',
          'description': 'Assign label(s) with a hierarchical label structure.',
          'image': 'assets/images/classification_hierarchical.png',
        },
      ]
    );
  }

  Widget _buildAnomalyTaskTypeSelection() {
    return TaskTypeGrid(
      selectedTaskType: _selectedTaskType,
      onTaskSelected: (value) => setState(() => _selectedTaskType = value),
      tasks: [
        {
          'title': 'Anomaly Detection',
          'description': 'Categorize images as normal or anomalous.',
          'image': 'assets/images/anomaly_detection.png',
        },
      ]
    );
  }

  Widget _buildChainedTasksSelection() {
    return TaskTypeGrid(
      selectedTaskType: _selectedTaskType,
      onTaskSelected: (value) => setState(() => _selectedTaskType = value),
      tasks: [
        {
          'title': 'Detection -> Classification',
          'description': 'Detect objects using bounding boxes followed by classification.',
          'image': 'assets/images/detection_to_classification.png',
        },
        {
          'title': 'Detection -> Segmentation',
          'description': 'Detect objects using bounding boxes followed by segmentation.',
          'image': 'assets/images/detection_to_segmentation.png',
        },
      ]
    );
  }
}
