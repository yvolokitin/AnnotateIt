import 'package:flutter/material.dart';

import '../../data/dataset_database.dart';
import '../../models/label.dart';
import '../../models/project.dart';
import '../../models/dataset.dart';

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
            children: const [
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
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: datasets.length,
                      itemBuilder: (context, index) {
                        return _buildDatasetCard(datasets[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDatasetCard(Dataset dataset) {
    return Container(
      width: 320,
      height: 400,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dataset, size: 56),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dataset.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSmallStatCard('Media', dataset.mediaCount.toString(), Icons.image),
              const SizedBox(width: 12),
              _buildSmallStatCard('Annotations', dataset.annotationCount.toString(), Icons.label_outline),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Labels:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.project.labels?.map((label) {
                  return Chip(
                    label: Text(label.name),
                    backgroundColor: label.toColor().withOpacity(0.15),
                    labelStyle: TextStyle(color: label.toColor()),
                  );
                }).toList() ??
                [const Text('No labels')],
          ),
          const Spacer(),
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

  Widget _buildSmallStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
