import "package:file_picker/file_picker.dart";
import "package:uuid/uuid.dart";
import "dart:io";

import "package:flutter/material.dart";

import "../models/project.dart";
import "../models/dataset.dart";
import "../models/media_item.dart";

import "../data/dataset_database.dart";
import "../widgets/no_media_dialog.dart";

class DatasetViewPage extends StatefulWidget {
  final Project project;
  const DatasetViewPage(this.project, {super.key});

  @override
  _DatasetViewPageState createState() => _DatasetViewPageState();
}

class _DatasetViewPageState extends State<DatasetViewPage> with TickerProviderStateMixin {
  List<Dataset> datasets = [];
  Map<String, List<MediaItem>> mediaByDataset = {};
  late TabController _tabController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  Future<void> _loadDatasets() async {
    final fetchedDatasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);

    // Put default dataset first
    fetchedDatasets.sort((a, b) {
      if (a.id == widget.project.defaultDatasetId) return -1;
      if (b.id == widget.project.defaultDatasetId) return 1;
      return 0;
    });

    // Add virtual "+ Add" dataset tab
    final addTab = Dataset(
      id: 'virtual-add-tab',
      projectId: widget.project.id!,
      name: '+',
      description: '',
      createdAt: DateTime.now(),
    );
    fetchedDatasets.add(addTab);

    _tabController = TabController(length: fetchedDatasets.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    setState(() {
      datasets = fetchedDatasets;
      isLoading = false;
    });

    await _loadMediaForDataset(fetchedDatasets.first);
  }

  Future<void> _loadMediaForDataset(Dataset dataset) async {
    if (dataset.id == 'virtual-add-tab') return;

    final media = await DatasetDatabase.instance.fetchMediaForDataset(dataset.id);
    setState(() {
      mediaByDataset[dataset.id] = media;
    });
  }

  void _handleTabChange() {
    final currentDataset = datasets[_tabController.index];
    if (currentDataset.id == 'virtual-add-tab') {
      _createNewDataset();
    } else {
      _loadMediaForDataset(currentDataset);
    }
  }

  Future<void> _createNewDataset() async {
    final newDataset = await DatasetDatabase.instance.createDatasetForProject(
      projectId: widget.project.id!,
      name: 'Dataset ${datasets.length}', // Basic naming
    );

    setState(() {
      datasets.insert(datasets.length - 1, newDataset); // Insert before + tab
      mediaByDataset[newDataset.id] = [];
      _tabController = TabController(length: datasets.length, vsync: this);
      _tabController.addListener(_handleTabChange);
      _tabController.index = datasets.indexWhere((d) => d.id == newDataset.id);
    });

    _loadMediaForDataset(newDataset);
  }

  Widget _buildMediaPreview(MediaItem media) {
    if (media.type == MediaType.image && File(media.filePath).existsSync()) {
      return Image.file(
        File(media.filePath),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    } else if (media.type == MediaType.video) {
      return Icon(Icons.videocam, size: 48, color: Colors.white70);
    } else {
      return Icon(Icons.insert_drive_file, size: 48, color: Colors.white38);
    }
  }

  Future<void> _uploadMedia(Dataset dataset) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
    );

    if (result != null && result.files.isNotEmpty) {
      for (final file in result.files) {
        final ext = file.extension?.toLowerCase();
        final type = (ext == 'mp4' || ext == 'mov')
          ? MediaType.video
          : MediaType.image;

        final mediaItem = MediaItem(
          id: Uuid().v4(),
          datasetId: dataset.id,
          filePath: file.path!,
          type: type,
        );

        await DatasetDatabase.instance.insertMediaItem(mediaItem);
      }

      // Refresh the media list
      _loadMediaForDataset(dataset);
    }
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: datasets.map((ds) => Tab(text: ds.name)).toList(),
        labelStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.white60,
      ),
      body: Container(
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 3),
          ),
          child: TabBarView(
            controller: _tabController,
            children: datasets.map((dataset) {
              if (dataset.id == 'virtual-add-tab') {
                return Center(child: Text("Creating new dataset...", style: TextStyle(color: Colors.white60)));
              }

              final mediaItems = mediaByDataset[dataset.id] ?? [];
              if (mediaItems.isEmpty) {
                return NoMediaDialog(project_id: widget.project.id!, dataset_id: dataset.id);
              }

              return ListView.builder(
                itemCount: mediaItems.length,
                itemBuilder: (context, index) {
                  final media = mediaItems[index];
                  return ListTile(
                    leading: _buildMediaPreview(media),
                    title: Text(media.filePath, style: TextStyle(color: Colors.white)),
                    subtitle: Text(media.type.name, style: TextStyle(color: Colors.white70)),
                  );
                },
              );
            }).toList(),
          ),
        ),
    );
  }
}
