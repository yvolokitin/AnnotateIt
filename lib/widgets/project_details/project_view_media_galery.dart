import 'package:flutter/material.dart';

import '../dialogs/delete_image_dialog.dart';

import '../../utils/image_utils.dart' as image_utils;
import '../../models/annotated_labeled_media.dart';
import '../../models/media_item.dart';
import '../../models/dataset.dart';
import '../../models/label.dart';
import '../../models/project.dart';

import '../../data/dataset_database.dart';
import '../../data/project_database.dart';

import 'dataset_tab_content.dart';
import 'dataset_tab_bar.dart';

class ProjectViewMediaGalery extends StatefulWidget {
  final Project project;
  final String datasetId;
  final List<Label> labels;

  final void Function(AnnotatedLabeledMedia media, bool withAnnotations)? onImageDuplicated;

  const ProjectViewMediaGalery({
    required this.project,
    required this.datasetId,
    required this.labels,
    this.onImageDuplicated,
    super.key,
  });

  @override
  ProjectViewMediaGaleryState createState() => ProjectViewMediaGaleryState();
}

class ProjectViewMediaGaleryState extends State<ProjectViewMediaGalery> with TickerProviderStateMixin {
  Map<String, List<AnnotatedLabeledMedia>> annotatedMediaByDataset = {};
  List<Dataset> datasets = [];
  String currentDatasetId = '';
  TabController? _tabController;

  bool _isUploading = false;
  bool _cancelUpload = false;
  bool _uploadError = false;

  String? _uploadingFile;
  int _currentFileIndex = 0;
  double _uploadProgress = 0.0;

  int _fileCount = 0;
  int itemsPerPage = 24;
  int _totalPages = 0;
  int _currentPage = 0;

  bool _initialLoading = true;
  String? _lastLoadedDatasetId;

  final Map<String, Widget> _datasetTabCache = {};
  final MediaSortOption _sortOption = MediaSortOption.newestFirst;

  final Set<MediaItem> _selectedMediaItems = {};

  @override
  void initState() {
    super.initState();
    currentDatasetId = widget.datasetId;
    _loadDatasets();
  }

  Future<void> _loadDatasets() async {
    final fetchedDatasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);

    fetchedDatasets.sort((a, b) {
      if (a.id == widget.datasetId) return -1;
      if (b.id == widget.datasetId) return 1;
      return 0;
    });

    // Add the "+ tab" placeholder with required fields
    fetchedDatasets.add(Dataset(
      id: 'add_new_tab',
      projectId: widget.project.id!,
      datasetOrder: 0,
      name: '+',
      description: '',
      type: widget.project.type,
      source: 'manual',
      format: 'custom',
      version: '1.0.0',
      mediaCount: 0,
      annotationCount: 0,
      defaultDataset: false,
      license: null,
      metadata: null,
      folders: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    if (!mounted) return;
    setState(() {
      datasets = fetchedDatasets;
    });

    _rebuildTabController();
    if (currentDatasetId != null) {
      loadMediaForDataset(currentDatasetId, itemsPerPage, 0);
    }

    if (!mounted) return;
    setState(() {
      _initialLoading = false;
    });
  }

  Future<void> loadMediaForDataset(String datasetId, int itemsPerPage, int pageIndex) async {
    if (datasetId == 'add_new_tab') return;

    final totalCount = await DatasetDatabase.instance.countMediaItemsInDataset(datasetId);
    final totalPages = (totalCount / itemsPerPage).ceil();
    final annotatedList = await loadAnnotatedMediaForDataset(datasetId, itemsPerPage, pageIndex);

    if (!mounted) return;
    setState(() {
      annotatedMediaByDataset[datasetId] = annotatedList;
      _fileCount = totalCount;
      _totalPages = totalPages;
      _currentPage = 0;
      _datasetTabCache.remove(datasetId);
    });
  }

  Future<List<AnnotatedLabeledMedia>> loadAnnotatedMediaForDataset(String datasetId, int pageSize, int pageIndex) async {
    final offset = pageIndex * pageSize;
    final annotatedList = await DatasetDatabase.instance.fetchAnnotatedLabeledMediaBatch(
      datasetId: datasetId,
      offset: offset,
      limit: pageSize,
    );
// Sorting is disabled to preserve the original database order (based on offset).
// This ensures consistency between PaginatedImageGrid and AnnotatorPage,
// so that the clicked index points to the correct image without mismatch.
/*
    switch (_sortOption) {
      case MediaSortOption.newestFirst:
        annotatedList.sort((a, b) => b.mediaItem.uploadDate.compareTo(a.mediaItem.uploadDate));
        break;
      case MediaSortOption.oldestFirst:
        annotatedList.sort((a, b) => a.mediaItem.uploadDate.compareTo(b.mediaItem.uploadDate));
        break;
    }
*/
    return annotatedList;
  }

  void _handlePageChanged(int newPage) async {
    final datasetId = datasets[_tabController!.index].id;

    final annotatedList = await loadAnnotatedMediaForDataset(datasetId, itemsPerPage, newPage);

    setState(() {
      annotatedMediaByDataset[datasetId] = annotatedList;
      _currentPage = newPage;
      _datasetTabCache.remove(datasetId);
    });
  }

  Future<void> _handleDuplicateImage(
    AnnotatedLabeledMedia media,
    bool withAnnotations,
  ) async {
    await image_utils.duplicateMediaItem(
      original: media,
      datasetId: currentDatasetId,
      withAnnotations: withAnnotations,
    );

    await loadMediaForDataset(currentDatasetId, itemsPerPage, _currentPage);
  }
/*
  void _handleDeleteSelectedMedia() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteImageDialog(
        mediaItems: _selectedMediaItems.toList(),
        onConfirmed: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed == true) {
      for (final media in _selectedMediaItems) {
        await DatasetDatabase.instance.deleteMediaItemWithAnnotations(media.id!);
      }

      final datasetId = datasets[_tabController!.index].id;
      await loadMediaForDataset(datasetId, itemsPerPage, _currentPage);

      setState(() {
        _selectedMediaItems.clear();
      });
    }
  }
*/
  
void _handleDeleteSelectedMedia() async {
  final deletedPaths = await showDialog<List<String>>(
    context: context,
    builder: (context) => DeleteImageDialog(
      mediaItems: _selectedMediaItems.toList(),
      onConfirmed: (deletedPaths) => Navigator.pop(context, deletedPaths),
    ),
  );

  if (deletedPaths != null && deletedPaths.isNotEmpty) {
    // Remove deleted items from the current view
    setState(() {
      final currentDatasetId = datasets[_tabController!.index].id;
      final currentMediaList = annotatedMediaByDataset[currentDatasetId] ?? [];
      
      annotatedMediaByDataset[currentDatasetId] = currentMediaList.where((media) {
        return !deletedPaths.contains(media.mediaItem.filePath);
      }).toList();
      
      _selectedMediaItems.clear();
      _fileCount -= deletedPaths.length;
    });

    // Refresh the dataset from database
    final datasetId = datasets[_tabController!.index].id;
    await loadMediaForDataset(datasetId, itemsPerPage, _currentPage);
  }
}

  void _rebuildTabController() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    _tabController = TabController(length: datasets.length, vsync: this);
    _tabController!.addListener(_handleTabChange);
  }

  Future<void> _handleTabChange() async {
    final currentDataset = datasets[_tabController!.index];

    // 'add_new_tab' = create a new Dataset
    if (currentDataset.id == 'add_new_tab') {
      final newDataset = await DatasetDatabase.instance.createDatasetForProject(
        projectId: widget.project.id!,
        projectType: widget.project.type,
        name: 'Dataset ${datasets.length + 1}',
      );

      if (!mounted) return;
      setState(() {
        datasets.insert(datasets.length - 1, newDataset);
        annotatedMediaByDataset[newDataset.id] = [];
        currentDatasetId = newDataset.id;
      });

      _rebuildTabController();
      _tabController!.index = datasets.indexWhere((d) => d.id == newDataset.id);

    } else { // else load data
      if (_lastLoadedDatasetId == currentDataset.id) return;

      _lastLoadedDatasetId = currentDataset.id;
      loadMediaForDataset(currentDataset.id, itemsPerPage, 0);

      setState(() {
        currentDatasetId = currentDataset.id;
      });
    }
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

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _uploadingFile = null;
        _uploadProgress = 0.0;
        _currentFileIndex = 0;
      });
    });

    _resetCancelUpload();
    loadMediaForDataset(currentDataset.id, itemsPerPage, _currentPage);
    _datasetTabCache.remove(currentDataset.id);
  }

  void _handleUploadError() {
    if (!mounted) return;
    setState(() {
      _uploadError = true;
      _isUploading = false;
    });

    _resetCancelUpload();
  }

  void _resetCancelUpload() {
    if (!mounted) return;
    setState(() {
      _cancelUpload = false;
    });
  }

  void _renameDataset(Dataset dataset) async {
    final controller = TextEditingController(text: dataset.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Dataset'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Rename')),
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
    await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);

    setState(() {
      datasets.removeWhere((d) => d.id == dataset.id);
      datasets.insert(0, dataset);

      _rebuildTabController();
      _tabController!.index = 0;

      _datasetTabCache.clear();
    });
  }

  void _deleteDataset(Dataset dataset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dataset'),
        content: Text("Are you sure you want to delete '\${dataset.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await DatasetDatabase.instance.deleteDataset(dataset.id);
      await ProjectDatabase.instance.updateProjectLastUpdated(dataset.projectId);

      setState(() {
        datasets.removeWhere((d) => d.id == dataset.id);
        annotatedMediaByDataset.remove(dataset.id);
        _datasetTabCache.remove(dataset.id);
      });

      _rebuildTabController();
      if (_tabController!.index >= datasets.length) {
        _tabController!.index = datasets.length - 1;
      }

      loadMediaForDataset(datasets[_tabController!.index].id, itemsPerPage, 0);
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
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DatasetTabBar(
          controller: _tabController!,
          datasets: datasets,
          defaultDatasetId: widget.datasetId,
          onMenuAction: (dataset, action) {
            switch (action) {
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
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: datasets.map((dataset) {
              if (_datasetTabCache.containsKey(dataset.id)) {
                return _datasetTabCache[dataset.id]!;
              }

              final mediaItems = annotatedMediaByDataset[dataset.id];

              final widgetToRender = dataset.id == 'add_new_tab'
                  ? const Center(child: Text("Creating new dataset..."))
                  : DatasetTabContent(
                      project: widget.project,
                      datasetId: currentDatasetId,
                      labels: widget.labels,
                      mediaItems: mediaItems,
                      fileCount: _fileCount,
                      totalPages: _totalPages,
                      currentPage: _currentPage,
                      itemsPerPage: itemsPerPage,
                      isUploading: _isUploading,
                      cancelUpload: _cancelUpload,
                      onUploadingChanged: _handleUploadingChanged,
                      onUploadSuccess: _handleUploadSuccess,
                      onFileProgress: _handleFileUploadProgress,
                      onUploadError: _handleUploadError,
                      onPageChanged: _handlePageChanged,
                      onMediaDeleted: () {
                        loadMediaForDataset(dataset.id, itemsPerPage, _currentPage);
                      },
                      onItemsPerPageChanged: (int newItemsPerPage) {
                        loadMediaForDataset(dataset.id, newItemsPerPage, _currentPage);
                      },
                      onImageDuplicated: (media, withAnnotations) {
                        _handleDuplicateImage(media, withAnnotations);
                      },
                    );

              _datasetTabCache[dataset.id] = widgetToRender;
              return widgetToRender;
            }).toList(),
          ),
        ),
      ],
    );
  }
}

enum MediaSortOption {
  newestFirst,
  oldestFirst,
}
