import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import 'project_tabs/detection_tab.dart';
import 'project_tabs/classification_tab.dart';
import 'project_tabs/segmentation_tab.dart';

class CreateNewProjectStepTaskSelection extends StatefulWidget {
  final TextEditingController nameController;
  final String selectedTaskType;
  final Function(String tab, String task) onTaskSelectionChanged;

  const CreateNewProjectStepTaskSelection({
    Key? key,
    required this.nameController,
    required this.selectedTaskType,
    required this.onTaskSelectionChanged,
  }) : super(key: key);

  @override
  State<CreateNewProjectStepTaskSelection> createState() => _CreateNewProjectStepTaskSelectionState();
}

class _CreateNewProjectStepTaskSelectionState extends State<CreateNewProjectStepTaskSelection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    "Detection", "Classification", "Segmentation"
  ];
  String _selectedTab = "Detection";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return; // Wait until change settles

    setState(() {
      _selectedTab = _tabs[_tabController.index];
    });

    // Notify parent of current tab change with empty task if none selected
    widget.onTaskSelectionChanged(_selectedTab, "");
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.projectNameLabel,
            filled: true,
            fillColor: Colors.grey[850],
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
          ),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 20),
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
          tabs: _tabs.map((label) => Tab(text: label)).toList(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DetectionTab(
                selectedTaskType: widget.selectedTaskType,
                onSelected: (task) => widget.onTaskSelectionChanged("Detection", task),
              ),
              ClassificationTab(
                selectedTaskType: widget.selectedTaskType,
                onSelected: (task) => widget.onTaskSelectionChanged("Classification", task),
              ),
              SegmentationTab(
                selectedTaskType: widget.selectedTaskType,
                onSelected: (task) => widget.onTaskSelectionChanged("Segmentation", task),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
