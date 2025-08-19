import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import '../data/user_database.dart';

/// A singleton service that manages the current logged-in or active user in memory.
class UserSession {
  final _logger = Logger('UserSession');

  static final UserSession instance = UserSession._internal();
  UserSession._internal();

  User? _currentUser;

  //==================================================
  // Core
  //==================================================

  bool get isInitialized => _currentUser != null;

  void setUser(User user) {
    _currentUser = user;
  }

  User getUser() {
    if (_currentUser == null) {
      throw Exception("UserSession not initialized. Call setUser() first.");
    }
    return _currentUser!;
  }

  void clear() {
    _currentUser = null;
  }

  //==================================================
  // Helpers
  //==================================================

  /// If [stored] is an absolute path — return it normalized.
  /// If it's relative — resolve to `<Documents>/AnnotateIt/<stored>`.
  Future<String> _resolveFolder(String stored) async {
    if (stored.isEmpty) return stored;
    final isAbs = path.isAbsolute(stored);
    if (isAbs) return path.normalize(stored);

    final docsDir = await getApplicationDocumentsDirectory();
    return path.join(docsDir.path, 'AnnotateIt', stored);
  }

  Future<String> _ensureDir(String folder) async {
    final dir = Directory(folder);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      _logger.info('Created folder: $folder');
    }
    return folder;
    }

  //==================================================
  // GETTERS (simple flags/values)
  //==================================================

  bool get autoSaveAnnotations => getUser().autoSaveAnnotations;

  bool get askConfirmationOnAnnotationRemoval =>
      getUser().askConfirmationOnAnnotationRemoval;

  bool get showExportLabelsButton => getUser().showExportLabelsButton;

  //==================================================
  // GETTERS (folders)
  //==================================================

  Future<String> getCurrentUserDatasetImportFolder() async {
    final folder = await _resolveFolder(getUser().datasetImportFolder);
    return _ensureDir(folder);
  }

  Future<String> getCurrentUserDatasetExportFolder() async {
    final folder = await _resolveFolder(getUser().datasetExportFolder);
    return _ensureDir(folder);
  }

  Future<String> getCurrentUserThumbnailFolder() async {
    final folder = await _resolveFolder(getUser().thumbnailFolder);
    return _ensureDir(folder);
  }

  Future<String> getCurrentUserModelsFolder() async {
    final folder = await _resolveFolder(getUser().modelsFolder);
    return _ensureDir(folder);
  }

  //==================================================
  // SETTERS (simple flags/values)
  //==================================================

  Future<void> setProjectSkipDeleteConfirm(bool skip) async {
    final user = getUser();
    await UserDatabase.instance.setProjectSkipDeleteConfirm(
      userId: user.id!,
      skip: skip,
    );
    _currentUser = user.copyWith(projectSkipDeleteConfirm: skip);
  }

  Future<void> setAutoSaveAnnotations(bool autoSave) async {
    final user = getUser();
    await UserDatabase.instance.setAutoSaveAnnotations(
      userId: user.id!,
      autoSave: autoSave,
    );
    _currentUser = user.copyWith(autoSaveAnnotations: autoSave);
  }

  Future<void> setAskConfirmationOnAnnotationRemoval(bool askConfirmation) async {
    final user = getUser();
    await UserDatabase.instance.setAskConfirmationOnAnnotationRemoval(
      userId: user.id!,
      askConfirmation: askConfirmation,
    );
    _currentUser =
        user.copyWith(askConfirmationOnAnnotationRemoval: askConfirmation);
  }

  Future<void> setProjectShowImportWarning(bool showWarning) async {
    final user = getUser();
    await UserDatabase.instance.update(
      user.copyWith(projectShowImportWarning: showWarning),
    );
    _currentUser = user.copyWith(projectShowImportWarning: showWarning);
    _logger.info('Updated project show import warning to: $showWarning');
  }

  Future<void> setShowExportLabelsButton(bool show) async {
    final user = getUser();
    await UserDatabase.instance.setShowExportLabelsButton(
      userId: user.id!,
      showExportLabelsButton: show,
    );
    _currentUser = user.copyWith(showExportLabelsButton: show);
    _logger.info('Updated show export labels button to: $show');
  }

  Future<void> setPreferredSamModelKey(String key) async {
    final user = getUser();
    final updated =
        user.copyWith(preferredSamModelKey: key, updatedAt: DateTime.now());
    await UserDatabase.instance.update(updated);
    _currentUser = updated;
    _logger.info('Updated preferred SAM model to: $key');
  }

  Future<void> setSamRememberChoice(bool remember) async {
    final user = getUser();
    final updated =
        user.copyWith(samRememberChoice: remember, updatedAt: DateTime.now());
    await UserDatabase.instance.update(updated);
    _currentUser = updated;
    _logger.info('Updated SAM remember choice to: $remember');
  }

  //==================================================
  // SETTERS (folders) — store as given (absolute or relative)
  //==================================================

  Future<void> setCurrentUserDatasetImportFolder(String absoluteOrRelativePath) async {
    final p = path.normalize(absoluteOrRelativePath);
    final user = getUser();
    final updated = user.copyWith(datasetImportFolder: p);
    await UserDatabase.instance.update(updated);
    _currentUser = updated;
    _logger.info('Updated dataset import folder to: $p');
  }

  Future<void> setCurrentUserDatasetExportFolder(String absoluteOrRelativePath) async {
    final p = path.normalize(absoluteOrRelativePath);
    final user = getUser();
    final updated = user.copyWith(datasetExportFolder: p);
    await UserDatabase.instance.update(updated);
    _currentUser = updated;
    _logger.info('Updated dataset export folder to: $p');
  }

  Future<void> setCurrentUserThumbnailFolder(String absoluteOrRelativePath) async {
    final p = path.normalize(absoluteOrRelativePath);
    final user = getUser();
    final updated = user.copyWith(thumbnailFolder: p);
    await UserDatabase.instance.update(updated);
    _currentUser = updated;
    _logger.info('Updated thumbnail folder to: $p');
  }

  Future<void> setCurrentUserModelsFolder(String absoluteOrRelativePath) async {
    final p = path.normalize(absoluteOrRelativePath);
    final user = getUser();
    final updated = user.copyWith(modelsFolder: p);
    await UserDatabase.instance.update(updated);
    _currentUser = updated;
    _logger.info('Updated models folder to: $p');
  }

  //==================================================
  // External tools
  //==================================================
  Future<void> setFfmpegPath(String? newPath) async {
    final user = getUser();
    final updated = user.copyWith(ffmpegPath: newPath?.trim().isEmpty == true ? null : newPath?.trim(), updatedAt: DateTime.now());
    await UserDatabase.instance.update(updated);
    _currentUser = updated;
    _logger.info('Updated ffmpegPath to: \'${updated.ffmpegPath ?? '(null)'}\'');
  }
}
