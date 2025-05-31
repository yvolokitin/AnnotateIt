import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../models/dataset.dart';
import '../../models/annotated_labeled_media.dart';
import '../data/dataset_database.dart';
import '../data/project_database.dart';

class DatasetViewModel extends ChangeNotifier {
  Project project;
  final DatasetDatabase datasetDb;
  final ProjectDatabase projectDb;

  List<Dataset> datasets = [];
  Map<String, List<AnnotatedLabeledMedia>> annotatedMediaByDataset = {};

  bool isLoading = true;
  bool isUploading = false;
  bool uploadError = false;
  double uploadProgress = 0.0;
  String? uploadingFileName;

  String? selectedDatasetId;
  MediaSortOption sortOption = MediaSortOption.newestFirst;

  DatasetViewModel({
    required this.project,
    required this.datasetDb,
    required this.projectDb,
  });

  Future<void> loadDatasets() async {
    isLoading = true;
    notifyListeners();

    datasets = await datasetDb.fetchDatasetsForProject(project.id!);
    datasets.sort((a, b) {
      if (a.id == project.defaultDatasetId) return -1;
      if (b.id == project.defaultDatasetId) return 1;
      return 0;
    });

    selectedDatasetId = datasets.first.id;
    await loadAnnotatedMediaForDataset(selectedDatasetId!);

    isLoading = false;
    notifyListeners();
    print("Datasets loaded: ${datasets.length}, Selected: $selectedDatasetId");
  }

  Future<void> loadAnnotatedMediaForDataset(String datasetId, {int pageSize = 24, int pageIndex = 0}) async {
    final offset = pageIndex * pageSize;
    final annotatedList = await datasetDb.fetchAnnotatedLabeledMediaBatch(
      datasetId: datasetId,
      offset: offset,
      limit: pageSize,
    );

    switch (sortOption) {
      case MediaSortOption.newestFirst:
        annotatedList.sort((a, b) => b.mediaItem.uploadDate.compareTo(a.mediaItem.uploadDate));
        break;
      case MediaSortOption.oldestFirst:
        annotatedList.sort((a, b) => a.mediaItem.uploadDate.compareTo(b.mediaItem.uploadDate));
        break;
    }

    annotatedMediaByDataset[datasetId] = annotatedList;
    notifyListeners();

    print("Loaded ${annotatedList.length} annotated media for dataset $datasetId at page $pageIndex");
  }

  void setUploading(bool uploading) {
    isUploading = uploading;
    if (!uploading) uploadingFileName = null;
    notifyListeners();
  }

  void updateUploadProgress(String filename, int index, int total) {
    uploadingFileName = filename;
    uploadProgress = index / total;
    notifyListeners();
  }

  void markUploadError() {
    uploadError = true;
    isUploading = false;
    notifyListeners();
  }

  void resetUploadState() {
    isUploading = false;
    uploadProgress = 0.0;
    uploadingFileName = null;
    notifyListeners();
  }

  Future<void> createDataset(String name) async {
    final newDataset = await datasetDb.createDatasetForProject(
      projectId: project.id!,
      name: name,
    );
    datasets.add(newDataset);
    notifyListeners();
  }

  Future<void> renameDataset(Dataset dataset, String newName) async {
    final updated = dataset.copyWith(name: newName);
    await datasetDb.updateDataset(updated);
    await projectDb.updateProjectLastUpdated(updated.projectId);

    final index = datasets.indexWhere((d) => d.id == dataset.id);
    datasets[index] = updated;
    notifyListeners();
  }

  Future<void> deleteDataset(Dataset dataset) async {
    await datasetDb.deleteDataset(dataset.id);
    datasets.removeWhere((d) => d.id == dataset.id);
    annotatedMediaByDataset.remove(dataset.id);
    notifyListeners();
  }

  Future<void> setDefaultDataset(Dataset dataset) async {
    await projectDb.updateDefaultDataset(
      projectId: project.id!,
      datasetId: dataset.id,
    );
    await projectDb.updateProjectLastUpdated(dataset.projectId);

    project = project.copyWith(defaultDatasetId: dataset.id);
    datasets.remove(dataset);
    datasets.insert(0, dataset);
    selectedDatasetId = dataset.id;
    notifyListeners();
  }
}

enum MediaSortOption {
  newestFirst,
  oldestFirst,
}
