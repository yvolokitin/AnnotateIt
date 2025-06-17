import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/dataset_database.dart';
import '../../models/label.dart';
import '../../models/project.dart';
import '../../models/dataset.dart';

import "../../utils/date_utils.dart";

import '../project_list/labels_list.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  Future<void> _loadDatasets() async {
    final fetched = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);
    setState(() {
      datasets = fetched;
      _isLoading = false;
    });
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
                  style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: datasets.map((dataset) {
                      return SizedBox(
                        width: 520,
                        height: 560,
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
    final labelFontSize = screenWidth < 600 ? 14.0 : 16.0;

    return Container(
      //width: 220,
      //height: 280,
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/icons/icons8-folder-64.png',
                fit: BoxFit.cover,
                height: 70, width: 70,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dataset.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(color: Colors.grey),
          const SizedBox(height: 25),

          Row(
            children: [
              _buildSmallStatCard('Media files', dataset.mediaCount.toString(), 'assets/icons/icons8-gallery-96.png',),
              const SizedBox(width: 12),
              _buildSmallStatCard('Annotations', dataset.annotationCount.toString(), 'assets/icons/icons8-label-64.png',),
            ],
          ),

          const SizedBox(height: 25),
          Row(
            children: [
              Icon(Icons.document_scanner),
              const SizedBox(width: 5),
              Text(dataset.type, style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
              const Spacer(),
              Icon(Icons.watch_later_outlined),
              const SizedBox(width: 5),
              Text(
                formatDate(dataset.createdAt),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal
                  ),
                ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Icon(Icons.source),
              const SizedBox(width: 5),
              Text('Source ${dataset.source}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
            ],
          ),

          const SizedBox(height: 25),
          const Text('Labels:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          LabelList(
            labels: widget.project.labels ?? [],
            projectName: widget.project.name,
            iconPath: widget.project.icon,
            fontLabelSize: labelFontSize,
          ),

          const Spacer(),
          const Divider(color: Colors.grey),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.copy), onPressed: () {}),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              IconButton(icon: const Icon(Icons.download), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, String icon) {
    return Container(
        height: 72,
        width: 232,
        padding: const EdgeInsets.all(10),
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
              icon, fit: BoxFit.cover,
              height: 50, width: 50,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: 18)),
                Text(value, style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          ],
        ),
    );
  }
}
