import 'dart:io';
import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/dataset.dart';
import '../models/media_item.dart';

import '../data/dataset_database.dart';
import '../data/project_database.dart';

import '../widgets/no_media_dialog.dart';
import '../widgets/dataset_upload_buttons.dart';
import '../widgets/paginated_image_grid.dart';

enum MediaSortOption {
  newestFirst,
  oldestFirst,
  // fileSize, not implemented yet in MediaSize
  // type, not implemented yet in MediaSize
}

class DatasetViewPage extends StatefulWidget {
  Project project;
  DatasetViewPage(this.project, {super.key});

  @override
  DatasetViewPageState createState() => DatasetViewPageState();
}

class DatasetViewPageState extends State<DatasetViewPage> with TickerProviderStateMixin {
  List<Dataset> datasets = [];
  Map<String, List<MediaItem>> mediaByDataset = {};
  TabController? _tabController;

  bool _isUploading = false;
  bool _uploadError = false;
  bool _cancelUpload = false;

  String? _uploadingFile;
  int _currentFileIndex = 0;
  int _fileCount = 0;
  double _uploadProgress = 0.0;

  // needed to show global spinner before datasets + media are fully ready
  bool _initialLoading = true;
  String? _lastLoadedDatasetId;

  // cache map for dataset tabs to avoid blink when switching tabs
  final Map<String, Widget> _datasetTabCache = {};

  final MediaSortOption _sortOption = MediaSortOption.newestFirst;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  void _rebuildTabController() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    _tabController = TabController(length: datasets.length, vsync: this);
    _tabController!.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    final currentDataset = datasets[_tabController!.index];

    if (currentDataset.id == 'add_new_tab') {
      _createNewDataset();
      return;
    }

    // Prevent duplicate calls
    if (_lastLoadedDatasetId == currentDataset.id) return;

    _lastLoadedDatasetId = currentDataset.id;
    _loadMediaForDataset(currentDataset);
  }

  void _handleUploadingChanged(bool uploading) {
    if (!mounted) return;
    setState(() {
      _isUploading = uploading;
      if (!uploading) _uploadingFile = null;
    });
  }

  void _handleFileUploadProgress(String filename, int index, int total) {
    if (!mounted) return;
    setState(() {
      _uploadingFile = filename;
      _currentFileIndex = index;
      _uploadProgress = index / total;
    });
  }

  void _handleUploadSuccess() {
    final currentDataset = datasets[_tabController!.index];

    if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _uploadingFile = null;
        _uploadProgress = 0.0;
        _currentFileIndex = 0;
      });
    });

    _resetCancelUpload();
    _loadMediaForDataset(currentDataset);

    // force rebuild after fresh data
    _datasetTabCache.remove(currentDataset.id);
  }

  void _handleUploadError() {
    if (!mounted) return;
    setState(() {
      _uploadError = true;
      _isUploading = false;
    });

    _resetCancelUpload();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Upload failed")),
    );
  }

  void _resetCancelUpload() {
    if (!mounted) return;
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

    if (!mounted) return;
    setState(() {
      datasets = fetchedDatasets;
    });

    _rebuildTabController();

    await _loadMediaForDataset(fetchedDatasets.first);

    if (!mounted) return;
    setState(() {
      _initialLoading = false;
    });
  }

  Future<void> _loadMediaForDataset(Dataset dataset) async {
    if (dataset.id == 'add_new_tab') return;

    final media = await DatasetDatabase.instance.fetchMediaForDataset(dataset.id);

    if (!mounted) return;

    List<MediaItem> sortedMedia = [...media]; 
    switch (_sortOption) {
      case MediaSortOption.newestFirst:
        sortedMedia.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        break;
      case MediaSortOption.oldestFirst:
        sortedMedia.sort((a, b) => a.uploadDate.compareTo(b.uploadDate));
        break;
    }

    setState(() {
      mediaByDataset[dataset.id] = sortedMedia;
      _fileCount = media.length;
      _datasetTabCache.remove(dataset.id);
    });

    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> _createNewDataset() async {
    final newDataset = await DatasetDatabase.instance.createDatasetForProject(
      projectId: widget.project.id!,
      name: 'Dataset ${datasets.length}',
    );

    if (!mounted) return;
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

  void _renameDataset(Dataset dataset) async {
    final controller = TextEditingController(text: dataset.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Dataset'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text('Rename')),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final updated = dataset.copyWith(name: result.trim());
      await DatasetDatabase.instance.updateDataset(updated);
      await ProjectDatabase.instance.updateProjectLastUpdated(updated.projectId);

      setState(() {
        final index = datasets.indexWhere((d) => d.id == dataset.id);
        datasets[index] = updated;
        _datasetTabCache.remove(updated.id);
      });
    }
  }

  void _setDefaultDataset(Dataset dataset) async {
    await ProjectDatabase.instance.updateDefaultDataset(projectId: widget.project.id!, datasetId: dataset.id);
    await ProjectDatabase.instance.updateProjectLastUpdated(dataset.projectId);

    setState(() {
      widget.project = widget.project.copyWith(defaultDatasetId: dataset.id);

      datasets.removeWhere((d) => d.id == dataset.id);
      datasets.insert(0, dataset);

      _rebuildTabController();
      _tabController!.index = 0;

      _datasetTabCache.clear();
    });
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Default dataset set to '${dataset.name}'")));
  }

  void _deleteDataset(Dataset dataset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Dataset'),
        content: Text("Are you sure you want to delete '${dataset.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await DatasetDatabase.instance.deleteDataset(dataset.id);
      await ProjectDatabase.instance.updateProjectLastUpdated(dataset.projectId);

      setState(() {
        datasets.removeWhere((d) => d.id == dataset.id);
        mediaByDataset.remove(dataset.id);
        _datasetTabCache.remove(dataset.id);
      });

      _rebuildTabController();
      if (_tabController!.index >= datasets.length) {
        _tabController!.index = datasets.length - 1;
      }

      _loadMediaForDataset(datasets[_tabController!.index]);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading || _tabController == null) {
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
              tabs: List.generate(datasets.length, (i) {
                final dataset = datasets[i];
                final isSelected = _tabController!.index == i;
                final isDefault = dataset.id == widget.project.defaultDatasetId;
                final isAddTab = dataset.id == 'add_new_tab';

                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dataset.name,
                        style: TextStyle(
                          fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (!isAddTab && isSelected)
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            switch (value) {
                              case 'rename':
                                _renameDataset(dataset);
                                break;
                              case 'set_default':
                                _setDefaultDataset(dataset);
                                break;
                              case 'delete':
                                _deleteDataset(dataset);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'rename',
                              child: Text('Rename'),
                            ),
                            if (!isDefault)
                              const PopupMenuItem(
                                value: 'set_default',
                                child: Text('Set as Default'),
                              ),
                              if (!isDefault)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                            ],
                          icon: Icon(Icons.more_vert, size: 18),
                        ),
                    ],
                  ),
                );
              }),
              indicatorColor: Colors.redAccent,
              labelStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.white60,
            ),  
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: datasets.map((dataset) {

                  if (_datasetTabCache.containsKey(dataset.id)) {
                    return _datasetTabCache[dataset.id]!;
                  }

                  final mediaItems = mediaByDataset[dataset.id];

                  final widgetToRender = dataset.id == 'add_new_tab'
                    ? Center(child: Text("Creating new dataset...", style: TextStyle(color: Colors.white60)))
                    : Column(
                      children: [
                        DatasetUploadButtons(
                          project_id: widget.project.id!,
                          project_icon: widget.project.icon,
                          dataset_id: dataset.id,
                          file_count: _fileCount,
                          isUploading: _isUploading,
                          onUploadingChanged: _handleUploadingChanged,
                          onUploadSuccess: _handleUploadSuccess,
                          onFileProgress: _handleFileUploadProgress,
                          onUploadError: _handleUploadError,
                          cancelUpload: _cancelUpload,
                        ),
                        Expanded(
                          child: (mediaItems == null || mediaItems.isEmpty)
                          ? NoMediaDialog(
                            project_id: widget.project.id!,
                            dataset_id: dataset.id,
                          )
                          : PaginatedImageGrid(
                            mediaItems: mediaItems,
                            project: widget.project,
                          ),
                        ),
                      ],  
                    );

                    _datasetTabCache[dataset.id] = widgetToRender;
                    return widgetToRender;
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
