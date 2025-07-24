import 'package:flutter/material.dart';

import '../dialogs/delete_image_dialog.dart';
import '../dialogs/delete_dataset_dialog.dart';
import '../dialogs/edit_dataset_name_dialog.dart';
import '../dialogs/upload_progress_dialog.dart';

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

  final void Function(AnnotatedLabeledMedia media, bool withAnnotations)? onImageDuplicated;
  
  /// Callback to notify when upload status changes
  final void Function(bool isUploading)? onUploadStatusChanged;

  const ProjectViewMediaGalery({
    required this.project,
    required this.datasetId,
    this.onImageDuplicated,
    this.onUploadStatusChanged,
    super.key,
  });

  @override
  ProjectViewMediaGaleryState createState() => ProjectViewMediaGaleryState();
}

class ProjectViewMediaGaleryState extends State<ProjectViewMediaGalery> with TickerProviderStateMixin {
  Map<String, List<AnnotatedLabeledMedia>> annotatedMediaByDataset = {};
  bool _dependenciesInitialized = false;
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
  
  // Global key to access the UploadProgressManagerState
  final GlobalKey<UploadProgressManagerState> _uploadProgressKey = GlobalKey<UploadProgressManagerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesInitialized) {
      final screenWidth = MediaQuery.of(context).size.width;
      // for mobile devices, use smaller items per page
      if (screenWidth < 1024) {
        itemsPerPage = 8;
      }

      currentDatasetId = widget.datasetId;
      _loadDatasets();

      _dependenciesInitialized = true;
    }
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

  /// Handles changes in upload status
  /// 
  /// This method is called by DatasetTabContent when the upload status changes.
  /// It updates the local state and notifies parent components about the change,
  /// allowing them to show a confirmation dialog when the user tries to navigate
  /// away during an active upload.
  /// 
  /// @param uploading Whether there's an active upload in progress
  void _handleUploadingChanged(bool uploading) {
    if (!mounted) return;
    setState(() {
      _isUploading = uploading;
      if (!uploading) _uploadingFile = null;
    });
    
    // Notify parent components about upload status change
    widget.onUploadStatusChanged?.call(uploading);
  }

  void _handleFileUploadProgress(String filename, int index, int total) {
    if (!mounted) return;
    
    // If cancellation was requested, clear the files when the upload process detects it
    if (_cancelUpload) {
      // Clear the upload progress dialog after a short delay to show cancellation status
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        
        // Clear the dialog and reset state
        _uploadProgressKey.currentState?.clearFiles();
        setState(() {
          _uploadingFile = null;
          _currentFileIndex = 0;
          _uploadProgress = 0.0;
          _isUploading = false;
          _cancelUpload = false;
        });
      });
      
      return;
    }
    
    setState(() {
      _uploadingFile = filename;
      _currentFileIndex = index;
      _uploadProgress = index / total;
    });
    
    // Update the upload progress dialog
    _uploadProgressKey.currentState?.updateFileProgress(filename, index, total);
  }

  void _handleUploadSuccess() {
    final currentDataset = datasets[_tabController!.index];

    if (!mounted) return;
    setState(() {
      _uploadProgress = 1.0;
      _uploadError = false;
    });

    // Clear the upload progress dialog after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _uploadingFile = null;
        _uploadProgress = 0.0;
        _currentFileIndex = 0;
      });
      
      // Clear the upload progress dialog
      _uploadProgressKey.currentState?.clearFiles();
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

  /// Resets the cancel upload flag
  /// 
  /// This method is called after a successful upload or an upload error.
  /// It should not be called when the user explicitly cancels the upload,
  /// as that is handled in _handleFileUploadProgress.
  void _resetCancelUpload() {
    if (!mounted) return;
    setState(() {
      _cancelUpload = false;
    });
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

  void _renameDataset(Dataset dataset) async {
    await showDialog<Dataset>(
      context: context,
      builder: (context) => EditDatasetNameDialog(
        dataset: dataset,
        onDatasetNameUpdated: (updated) {
          setState(() {
            final index = datasets.indexWhere((d) => d.id == dataset.id);
            datasets[index] = updated;
            _datasetTabCache.remove(updated.id);
          });
        },
      ),
    );
  }

  void _deleteDataset(Dataset dataset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteDatasetDialog(dataset: dataset),
    );

    if (confirmed == true) {
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

    final content = Column(
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
                      labels: widget.project.labels ?? [],
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
                      onRefreshNeeded: () {
                        loadMediaForDataset(dataset.id, itemsPerPage, _currentPage);
                      },
                    );
                    
              _datasetTabCache[dataset.id] = widgetToRender;
              return widgetToRender;
            }).toList(),
          ),
        ),
      ],
    );
    
    // Wrap the content with the UploadProgressManager
    return UploadProgressManager(
      key: _uploadProgressKey,
      onCancelUpload: () {
        setState(() {
          _cancelUpload = true;
        });
      },
      child: content,
    );
  }
}

enum MediaSortOption {
  newestFirst,
  oldestFirst,
}
