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
    super.key,
    required this.nameController,
    required this.selectedTaskType,
    required this.onTaskSelectionChanged,
  });

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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: TextStyle(color: Color(0xFFCC9966), fontWeight: FontWeight.normal, fontSize: 22),
        ),

        TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepOrangeAccent,
          indicatorWeight: 3.0,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Color(0xFFB28F7D),
          labelStyle: const TextStyle(fontSize: 24),
          unselectedLabelStyle: const TextStyle(fontSize: 24),
          tabs: _tabs.map((label) => Tab(text: label)).toList(),
        ),

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
