import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

import 'project_tabs/detection_tab.dart';
import 'project_tabs/classification_tab.dart';
import 'project_tabs/segmentation_tab.dart';
import '../../utils/theme.dart';

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
  State<CreateNewProjectStepTaskSelection> createState() =>
      _CreateNewProjectStepTaskSelectionState();
}

class _CreateNewProjectStepTaskSelectionState
    extends State<CreateNewProjectStepTaskSelection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["Detection", "Classification", "Segmentation"];
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
    final screenWidth = MediaQuery.of(context).size.width;
    final tabFs = screenWidth > 1200
        ? 16.0
        : screenWidth > 800
            ? 15.0
            : screenWidth > 500
                ? 14.0
                : 12.0;
    final inputFs = screenWidth > 1200
        ? 20.0
        : screenWidth > 800
            ? 18.0
            : 16.0;

    return Column(
      children: [
        // Project name input
        TextField(
          controller: widget.nameController,
          cursorColor: Colors.white,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: inputFs,
          ),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.projectNameLabel,
            labelStyle: TextStyle(color: Colors.white38, fontSize: inputFs - 2),
            filled: true,
            fillColor: AppColors.darkSurface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: screenWidth > 800 ? 16 : 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withAlpha(31)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        SizedBox(height: screenWidth > 800 ? 20 : 12),

        // Segmented pill-style tab bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            splashBorderRadius: BorderRadius.circular(10),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            labelStyle: TextStyle(
              fontSize: tabFs,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: tabFs,
              fontWeight: FontWeight.normal,
            ),
            labelPadding: EdgeInsets.zero,
            tabs: _tabs.map((label) {
              return Tab(
                height: screenWidth > 800 ? 42 : 36,
                child: Text(label),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: screenWidth > 800 ? 16 : 8),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DetectionTab(
                selectedTaskType: widget.selectedTaskType,
                onSelected: (task) =>
                    widget.onTaskSelectionChanged("Detection", task),
              ),
              ClassificationTab(
                selectedTaskType: widget.selectedTaskType,
                onSelected: (task) =>
                    widget.onTaskSelectionChanged("Classification", task),
              ),
              SegmentationTab(
                selectedTaskType: widget.selectedTaskType,
                onSelected: (task) =>
                    widget.onTaskSelectionChanged("Segmentation", task),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
