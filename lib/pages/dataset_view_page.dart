import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/app_database.dart';
import '../data/providers.dart';
import '../widgets/paginated_image_grid.dart';
import '../widgets/dataset_upload_buttons.dart';
import '../widgets/label_selection_dialog.dart';
import '../widgets/no_media_dialog.dart';

enum MediaSortOption {
  newestFirst,
  oldestFirst,
}

class DatasetViewPage extends ConsumerStatefulWidget {
  final Project project;
  const DatasetViewPage(this.project, {super.key});

  @override
  ConsumerState<DatasetViewPage> createState() => _DatasetViewPageState();
}

class _DatasetViewPageState extends ConsumerState<DatasetViewPage> with TickerProviderStateMixin {
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
  bool _initialLoading = true;
  MediaSortOption _sortOption = MediaSortOption.newestFirst;

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
    _loadMediaForDataset(currentDataset);
  }

  Future<void> _loadDatasets() async {
    final db = ref.read(databaseProvider);
    final fetched = await db.getAllDatasets();
    final filtered = fetched.where((d) => d.projectId == widget.project.id).toList();
    setState(() {
      datasets = filtered;
    });
    _rebuildTabController();
    await _loadMediaForDataset(datasets.first);
    setState(() {
      _initialLoading = false;
    });
  }

  Future<void> _loadMediaForDataset(Dataset dataset) async {
    final db = ref.read(databaseProvider);
    final media = await db.getAllMediaItems();
    final filtered = media.where((m) => m.datasetId == dataset.id).toList();
    List<MediaItem> sorted = [...filtered];
    switch (_sortOption) {
      case MediaSortOption.newestFirst:
        sorted.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        break;
      case MediaSortOption.oldestFirst:
        sorted.sort((a, b) => a.uploadDate.compareTo(b.uploadDate));
        break;
    }
    setState(() {
      mediaByDataset[dataset.id] = sorted;
      _fileCount = sorted.length;
    });
  }

  void _showDatasetDetails(Dataset dataset) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final createdAt = formatter.format(dataset.createdAt);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dataset Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${dataset.name}"),
            Text("Created: $createdAt"),
            if (dataset.description != null && dataset.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Description: ${dataset.description}"),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
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
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: datasets.map((ds) => Tab(text: ds.name)).toList(),
          labelStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.white60,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: datasets.map((dataset) {
              final mediaItems = mediaByDataset[dataset.id] ?? [];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Project: ${widget.project.name}",
                            style: const TextStyle(fontSize: 18)),
                        Text("Dataset: ${dataset.name}",
                            style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => _showDatasetDetails(dataset),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DatasetUploadButtons(
                      project_id: widget.project.id,
                      dataset_id: dataset.id,
                      project_icon: widget.project.icon,
                      file_count: _fileCount,
                      isUploading: _isUploading,
                      onUploadingChanged: (val) => setState(() => _isUploading = val),
                      onUploadSuccess: () => _loadMediaForDataset(dataset),
                      onFileProgress: (filename, index, total) {
                        setState(() {
                          _uploadingFile = filename;
                          _currentFileIndex = index;
                          _uploadProgress = index / total;
                        });
                      },
                      onUploadError: () => setState(() => _uploadError = true),
                      cancelUpload: _cancelUpload,
                    ),
                  ),
                  Expanded(
                    child: mediaItems.isEmpty
                        ? NoMediaDialog(
                            project_id: widget.project.id,
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
    );
  }
}
