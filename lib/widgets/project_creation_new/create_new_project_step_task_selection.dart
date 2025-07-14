import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

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
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedTab = _tabs[_tabController.index];
    });
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        TextField(
          controller: widget.nameController,
          cursorColor: Colors.white, 
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'CascadiaCode',
            fontWeight: FontWeight.normal,
            fontSize: screenWidth>1200 ? 22 : 18,
          ),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.projectNameLabel,
            labelStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.grey[850],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white24,
          labelStyle: TextStyle(
            fontSize: screenWidth>1200 ? 24 : 20,
            fontFamily: 'CascadiaCode',
            fontWeight: FontWeight.normal,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: screenWidth>1200 ? 24 : 20,
            fontFamily: 'CascadiaCode',
            fontWeight: FontWeight.normal,
          ),
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
