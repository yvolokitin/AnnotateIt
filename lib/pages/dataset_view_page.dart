import 'dart:io';
import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/dataset.dart';
import '../models/media_item.dart';

import '../data/dataset_database.dart';

import '../widgets/no_media_dialog.dart';
import '../widgets/dataset_upload_buttons.dart';
import '../widgets/paginated_image_grid.dart';

class DatasetViewPage extends StatefulWidget {
  final Project project;
  const DatasetViewPage(this.project, {super.key});

  @override
  _DatasetViewPageState createState() => _DatasetViewPageState();
}

class _DatasetViewPageState extends State<DatasetViewPage> with TickerProviderStateMixin {
  List<Dataset> datasets = [];
  Map<String, List<MediaItem>> mediaByDataset = {};
  TabController? _tabController;

  bool isLoading = true;
  bool _isUploading = false;
  bool _uploadError = false;
  bool _cancelUpload = false;

  String? _uploadingFile;
  int _currentFileIndex = 0;
  int _totalFiles = 0;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  void _rebuildTabController() {
    _tabController?.dispose();
    _tabController = TabController(length: datasets.length, vsync: this);
    _tabController!.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    final currentDataset = datasets[_tabController!.index];
    if (currentDataset.id == 'add_new_tab') {
      _createNewDataset();
    } else {
      _loadMediaForDataset(currentDataset);
    }
  }

  void _handleUploadingChanged(bool uploading) {
    setState(() {
      _isUploading = uploading;
      if (!uploading) _uploadingFile = null;
    });
  }

  void _handleFileUploadProgress(String filename, int index, int total) {
    setState(() {
      _uploadingFile = filename;
      _currentFileIndex = index;
      _totalFiles = total;
      _uploadProgress = index / total;
    });
  }

  void _handleUploadSuccess() {
    final currentDataset = datasets[_tabController!.index];

    setState(() {
      _uploadProgress = 1.0;
      _uploadError = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Upload completed: $_currentFileIndex file(s)"),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _uploadingFile = null;
        _uploadProgress = 0.0;
        _currentFileIndex = 0;
        _totalFiles = 0;
      });
    });

    _resetCancelUpload();
    _loadMediaForDataset(currentDataset);
  }

  void _handleUploadError() {
    setState(() {
      _uploadError = true;
      _isUploading = false;
    });

    _resetCancelUpload();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Upload failed")),
    );
  }

  void _resetCancelUpload() {
    setState(() {
      _cancelUpload = false;
    });
  }

  Future<void> _loadDatasets() async {
    final fetchedDatasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);

    fetchedDatasets.sort((a, b) {
      if (a.id == widget.project.defaultDatasetId) return -1;
      if (b.id == widget.project.defaultDatasetId) return 1;
      return 0;
    });

    fetchedDatasets.add(
      Dataset(
        id: 'add_new_tab',
        projectId: widget.project.id!,
        name: '+',
        description: '',
        createdAt: DateTime.now(),
      ),
    );

    setState(() {
      datasets = fetchedDatasets;
      isLoading = false;
    });

    _rebuildTabController();
    await _loadMediaForDataset(fetchedDatasets.first);
  }

  Future<void> _loadMediaForDataset(Dataset dataset) async {
    if (dataset.id == 'add_new_tab') return;

    final media = await DatasetDatabase.instance.fetchMediaForDataset(dataset.id);
    setState(() {
      mediaByDataset[dataset.id] = media;
    });
  }

  Future<void> _createNewDataset() async {
    final newDataset = await DatasetDatabase.instance.createDatasetForProject(
      projectId: widget.project.id!,
      name: 'Dataset ${datasets.length}',
    );

    setState(() {
      datasets.insert(datasets.length - 1, newDataset);
      mediaByDataset[newDataset.id] = [];
    });

    _rebuildTabController();
    _tabController!.index = datasets.indexWhere((d) => d.id == newDataset.id);

    _loadMediaForDataset(newDataset);
  }

  Widget _buildMediaPreview(MediaItem media) {
    if (media.type == MediaType.image && File(media.filePath).existsSync()) {
      return Image.file(File(media.filePath), width: 48, height: 48, fit: BoxFit.cover);
    } else if (media.type == MediaType.video) {
      return Icon(Icons.videocam, size: 48, color: Colors.white70);
    } else {
      return Icon(Icons.insert_drive_file, size: 48, color: Colors.white38);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || _tabController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: datasets.map((ds) => Tab(text: ds.name)).toList(),
              labelStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.white60,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: datasets.map((dataset) {
                  if (dataset.id == 'add_new_tab') {
                    return Center(
                      child: Text("Creating new dataset...", style: TextStyle(color: Colors.white60)),
                    );
                  }

                  final mediaItems = mediaByDataset[dataset.id] ?? [];

                  return Column(
                    children: [
                      DatasetUploadButtons(
                        project_id: widget.project.id!,
                        project_icon: widget.project.icon,
                        dataset_id: dataset.id,
                        isUploading: _isUploading,
                        onUploadingChanged: _handleUploadingChanged,
                        onUploadSuccess: _handleUploadSuccess,
                        onFileProgress: _handleFileUploadProgress,
                        onUploadError: _handleUploadError,
                        cancelUpload: _cancelUpload,
                      ),

                      Expanded(
                        child: mediaItems.isEmpty
                            ? NoMediaDialog(
                                project_id: widget.project.id!,
                                dataset_id: dataset.id,
                              )
                            : PaginatedImageGrid(mediaItems: mediaItems),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        if (_isUploading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: Colors.grey[850],
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _uploadingFile ?? "Uploading...",
                          style: TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          minHeight: 6,
                          color: _uploadError ? Colors.orange : Colors.green,
                          backgroundColor: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "${(_uploadProgress * 100).toInt()}%",
                    style: TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _cancelUpload = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Canceled upload")),
                      );
                    },
                    icon: Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
