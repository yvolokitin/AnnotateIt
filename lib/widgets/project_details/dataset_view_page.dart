import 'package:flutter/material.dart';

import '../../data/dataset_database.dart';
import '../../data/project_database.dart';

import '../../models/project.dart';
import '../../models/annotated_labeled_media.dart';

import '../../view_models/dataset_view_model.dart';

import 'no_media_dialog.dart';
import 'dataset_upload_buttons.dart';
import 'paginated_image_grid.dart';

class DatasetViewPage extends StatefulWidget {
  final Project project;
  const DatasetViewPage(this.project, {super.key});

  @override
  State<DatasetViewPage> createState() => _DatasetViewPageState();
}

class _DatasetViewPageState extends State<DatasetViewPage> with TickerProviderStateMixin {
  late final DatasetViewModel viewModel;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    viewModel = DatasetViewModel(
      project: widget.project,
      datasetDb: DatasetDatabase.instance,
      projectDb: ProjectDatabase.instance,
    );
    viewModel.loadDatasets().then((_) => _initTabController());
  }

  void _initTabController() {
    _tabController = TabController(length: viewModel.datasets.length, vsync: this);
    _tabController!.addListener(() async {
      if (_tabController!.indexIsChanging) return;
      final dataset = viewModel.datasets[_tabController!.index];
      await viewModel.loadAnnotatedMediaForDataset(dataset.id);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading || _tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: viewModel.datasets.map((dataset) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dataset.name,
                      style: TextStyle(
                        fontWeight: dataset.id == viewModel.project.defaultDatasetId
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              indicatorColor: Colors.redAccent,
              labelStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.white60,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: viewModel.datasets.map((dataset) {
                  final mediaItems = viewModel.annotatedMediaByDataset[dataset.id];

                  if (dataset.id == 'add_new_tab') {
                    return const Center(child: Text("Creating new dataset...", style: TextStyle(color: Colors.white60)));
                  }

                  return Column(
                    children: [
                      DatasetUploadButtons(
                        project_id: widget.project.id!,
                        project_icon: widget.project.icon,
                        dataset_id: dataset.id,
                        file_count: 0, // update if needed
                        isUploading: viewModel.isUploading,
                        onUploadingChanged: viewModel.setUploading,
                        onUploadSuccess: () => viewModel.loadAnnotatedMediaForDataset(dataset.id),
                        onFileProgress: viewModel.updateUploadProgress,
                        onUploadError: viewModel.markUploadError,
                        cancelUpload: () => viewModel.uploadError,
                      ),
                      Expanded(
                        child: (mediaItems == null || mediaItems.isEmpty)
                            ? NoMediaDialog(project_id: widget.project.id!, dataset_id: dataset.id)
                            : PaginatedImageGrid(annotatedMediaItems: mediaItems, project: widget.project),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        if (viewModel.isUploading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: Colors.grey[850],
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.uploadingFileName ?? "Uploading...",
                          style: const TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: viewModel.uploadProgress,
                          minHeight: 6,
                          color: viewModel.uploadError ? Colors.orange : Colors.green,
                          backgroundColor: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("${(viewModel.uploadProgress * 100).toInt()}%", style: const TextStyle(color: Colors.white)),
                  IconButton(
                    onPressed: viewModel.resetUploadState,
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
