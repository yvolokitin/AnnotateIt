import 'dart:io';
import 'package:flutter/material.dart';

import '../../data/dataset_database.dart';
import '../../models/project.dart';
import '../../models/dataset.dart';

import "../../utils/date_utils.dart";

import '../project_list/labels_list.dart';
import '../../widgets/dialogs/edit_dataset_name_dialog.dart';
import '../../pages/project_export/export_project_dialog.dart';

class ProjectViewDatasetsOverview extends StatefulWidget {
  final Project project;

  const ProjectViewDatasetsOverview({
    required this.project,
    super.key,
  });

  @override
  ProjectViewDatasetsOverviewState createState() => ProjectViewDatasetsOverviewState();
}

class ProjectViewDatasetsOverviewState extends State<ProjectViewDatasetsOverview> with TickerProviderStateMixin {
  List<Dataset> datasets = [];
  Map<String, int> datasetAnnotationCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when the widget becomes visible again
    if (!_isLoading && datasets.isNotEmpty) {
      _refreshAnnotationCounts();
    }
  }

  Future<void> _loadDatasets() async {
    final fetched = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);
    
    // Load actual annotation counts for each dataset
    Map<String, int> counts = {};
    for (var dataset in fetched) {
      counts[dataset.id] = await DatasetDatabase.instance.countAnnotationsForDataset(dataset.id);
    }
    
    setState(() {
      datasets = fetched;
      datasetAnnotationCounts = counts;
      _isLoading = false;
    });
  }
  
  Future<void> _refreshAnnotationCounts() async {
    Map<String, int> counts = {};
    for (var dataset in datasets) {
      counts[dataset.id] = await DatasetDatabase.instance.countAnnotationsForDataset(dataset.id);
    }
    
    setState(() {
      datasetAnnotationCounts = counts;
    });
  }
  
  Future<void> _openDatasetFolder(Dataset dataset) async {
    try {
      // Get folder IDs for the dataset
      final folderIds = await DatasetDatabase.instance.getFolderIdsForDataset(dataset.id);
      
      if (folderIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No folder found for this dataset')),
        );
        return;
      }
      
      // Get the path for the first folder (most datasets will have only one folder)
      final folderPath = await DatasetDatabase.instance.getMediaFolderPath(folderIds.first);
      
      if (folderPath == null || folderPath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder path not found')),
        );
        return;
      }
      
      // Open the folder in explorer
      await Process.run('explorer', [folderPath]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening folder: ${e.toString()}')),
      );
    }
  }
  
  void _renameDataset(Dataset dataset) async {
    await showDialog<Dataset>(
      context: context,
      builder: (context) => EditDatasetNameDialog(
        dataset: dataset,
        onDatasetNameUpdated: (updated) {
          setState(() {
            final index = datasets.indexWhere((d) => d.id == dataset.id);
            if (index != -1) {
              datasets[index] = updated;
            }
          });
        },
      ),
    );
  }
  
  void _exportDataset(Dataset dataset) async {
    // Show the export dialog
    await showDialog(
      context: context,
      builder: (context) => ExportProjectDialog(
        project: widget.project,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                'Datasets Overview',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CascadiaCode',
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.grey),
        const SizedBox(height: 25),
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : datasets.isEmpty
              ? const Center(
                child: Text(
                  'No datasets found.',
                  style: TextStyle(color: Colors.white, fontFamily: 'CascadiaCode'),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: datasets.map((dataset) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 300,
                          maxWidth: 520,
                        ),
                        child: _buildDatasetCard(dataset),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatasetCard(Dataset dataset) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive font sizes based on screen width
    final labelFontSize = screenWidth < 600 ? 14.0 : 16.0;
    final titleFontSize = screenWidth < 600 ? 18.0 : 22.0;
    final contentFontSize = screenWidth < 600 ? 14.0 : 18.0;
    
    // Responsive padding based on screen width
    final cardPadding = screenWidth < 600 ? 12.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black,
            blurRadius: 12,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/icons/icons8-folder-64.png',
                fit: BoxFit.cover,
                height: screenWidth < 600 ? 50 : 70, 
                width: screenWidth < 600 ? 50 : 70,
              ),
              SizedBox(width: screenWidth < 600 ? 8 : 10),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  dataset.name,
                  style: TextStyle(
                    fontSize: titleFontSize, 
                    fontWeight: FontWeight.normal, 
                    fontFamily: 'CascadiaCode'
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),

          SizedBox(height: screenWidth < 600 ? 10 : 15),
          const Divider(color: Colors.grey),
          SizedBox(height: screenWidth < 600 ? 15 : 25),

          // Wrap stat cards in a responsive layout
          screenWidth < 450 
          ? Column(
              children: [
                _buildSmallStatCard('Media files', dataset.mediaCount.toString(), 'assets/icons/icons8-gallery-96.png'),
                SizedBox(height: 12),
                _buildSmallStatCard('Annotations', (datasetAnnotationCounts[dataset.id] ?? 0).toString(), 'assets/icons/icons8-label-64.png'),
              ],
            )
          : Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: _buildSmallStatCard('Media files', dataset.mediaCount.toString(), 'assets/icons/icons8-gallery-96.png'),
                ),
                SizedBox(width: screenWidth < 600 ? 8 : 12),
                Flexible(
                  fit: FlexFit.loose,
                  child: _buildSmallStatCard('Annotations', (datasetAnnotationCounts[dataset.id] ?? 0).toString(), 'assets/icons/icons8-label-64.png'),
                ),
              ],
            ),

          SizedBox(height: screenWidth < 600 ? 15 : 25),
          // Type and date always in two rows
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.document_scanner, size: screenWidth < 600 ? 18 : 24),
                  SizedBox(width: screenWidth < 600 ? 3 : 5),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      dataset.type, 
                      style: TextStyle(
                        fontSize: contentFontSize, 
                        fontWeight: FontWeight.normal, 
                        fontFamily: 'CascadiaCode'
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.watch_later_outlined, size: screenWidth < 600 ? 18 : 24),
                  SizedBox(width: screenWidth < 600 ? 3 : 5),
                  Flexible(
                    child: Text(
                      formatDate(dataset.createdAt),
                      style: TextStyle(
                        fontSize: contentFontSize,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'CascadiaCode'
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: screenWidth < 600 ? 15 : 25),

          Row(
            children: [
              Icon(Icons.source_outlined, size: screenWidth < 600 ? 18 : 24),
              SizedBox(width: screenWidth < 600 ? 3 : 5),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  'Source ${dataset.source}', 
                  style: TextStyle(
                    fontSize: contentFontSize, 
                    fontWeight: FontWeight.normal, 
                    fontFamily: 'CascadiaCode'
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),

          SizedBox(height: screenWidth < 600 ? 15 : 25),
          Text(
            'Labels:', 
            style: TextStyle(
              fontSize: contentFontSize, 
              fontWeight: FontWeight.bold, 
              fontFamily: 'CascadiaCode'
            )
          ),
          SizedBox(height: screenWidth < 600 ? 10 : 20),

          // The LabelList widget already uses responsive fontLabelSize
          LabelList(
            labels: widget.project.labels ?? [],
            projectName: widget.project.name,
            iconPath: widget.project.icon,
            fontLabelSize: labelFontSize,
          ),

          SizedBox(height: screenWidth < 600 ? 15 : 25),
          const Divider(color: Colors.grey),
          SizedBox(height: screenWidth < 600 ? 15 : 25),
          
          // For very small screens, use a Wrap widget to allow buttons to flow to next line if needed
          screenWidth < 350
          ? Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 8,
              runSpacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  iconSize: screenWidth < 600 ? 20 : 24,
                  onPressed: () => _openDatasetFolder(dataset),
                  padding: EdgeInsets.all(screenWidth < 600 ? 8 : 12),
                  tooltip: 'Open folder in explorer',
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  iconSize: screenWidth < 600 ? 20 : 24,
                  onPressed: () => _renameDataset(dataset),
                  padding: EdgeInsets.all(screenWidth < 600 ? 8 : 12),
                  tooltip: 'Rename dataset',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  iconSize: screenWidth < 600 ? 20 : 24,
                  onPressed: () => _exportDataset(dataset),
                  padding: EdgeInsets.all(screenWidth < 600 ? 8 : 12),
                  tooltip: 'Export dataset',
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  iconSize: screenWidth < 600 ? 20 : 24,
                  onPressed: () => _openDatasetFolder(dataset),
                  tooltip: 'Open folder in explorer',
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  iconSize: screenWidth < 600 ? 20 : 24,
                  onPressed: () => _renameDataset(dataset),
                  tooltip: 'Rename dataset',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  iconSize: screenWidth < 600 ? 20 : 24,
                  onPressed: () => _exportDataset(dataset),
                  tooltip: 'Export dataset',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, String icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 14.0 : 18.0;
    final iconSize = screenWidth < 600 ? 40.0 : 50.0;
    final padding = screenWidth < 600 ? 8.0 : 10.0;
    final spacing = screenWidth < 600 ? 10.0 : 15.0;
    
    return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              icon, 
              fit: BoxFit.cover,
              height: iconSize, 
              width: iconSize,
            ),
            SizedBox(width: spacing),
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title, 
                    style: TextStyle(fontSize: fontSize, fontFamily: 'CascadiaCode'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value, 
                    style: TextStyle(fontSize: fontSize, color: Colors.grey, fontFamily: 'CascadiaCode'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
