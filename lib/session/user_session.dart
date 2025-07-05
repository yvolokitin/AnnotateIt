import 'dart:io';
import 'package:logging/logging.dart';

import '../models/user.dart';
import '../data/user_database.dart';

/// A singleton service that manages the current logged-in or active user in memory.
///
/// The [UserSession] class provides fast and global access to the current user,
/// without the need to query the database repeatedly. It is initialized once 
/// during app startup, typically right after fetching the user from SQLite using
/// [UserDatabase].
///
/// This class is especially useful for:
/// - Tagging media items with `ownerId`
/// - Accessing user preferences (e.g., theme, language)
/// - Persisting consistent user context across the app lifecycle
///
/// Example:
/// ```dart
/// // During app startup
/// final user = await UserDatabase.instance.getUser();
/// if (user != null) {
///   UserSession.instance.setUser(user);
/// }
///
/// // Anywhere in the app
/// final currentUser = UserSession.instance.getUser();
/// print(currentUser.email);
/// ```
class UserSession {
  final _logger = Logger('UserSession');

  static final UserSession instance = UserSession._internal();
  UserSession._internal();

  User? _currentUser;

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

  Future<void> setProjectSkipDeleteConfirm(bool skip) async {
    final user = getUser();
    await UserDatabase.instance.setProjectSkipDeleteConfirm(
      userId: user.id!,
      skip: skip,
    );

    _currentUser = user.copyWith(projectSkipDeleteConfirm: skip);
  }

  bool get autoSaveAnnotations {
    return getUser().autoSaveAnnotations;
  }

  Future<void> setAutoSaveAnnotations(bool autoSave) async {
    final user = getUser();
    await UserDatabase.instance.setAutoSaveAnnotations(
      userId: user.id!,
      autoSave: autoSave,
    );
    _currentUser = user.copyWith(autoSaveAnnotations: autoSave);
  }

  Future<String> getCurrentUserDatasetImportFolder() async {
    final path = getUser().datasetImportFolder;
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      _logger.info('Created dataset import folder: $path');
    }
    return path;
  }

  Future<String> getCurrentUserDatasetExportFolder() async {
    final path = getUser().datasetExportFolder;
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      _logger.info('Created dataset export folder: $path');
    }
    return path;
  }

  Future<String> getCurrentUserThumbnailFolder() async {
    final path = getUser().thumbnailFolder;
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      _logger.info('Created thumbnail folder: $path');
    }
    return path;
  }

  Future<void> setCurrentUserDatasetImportFolder(String path) async {
    final user = getUser();
    await UserDatabase.instance.update(
      user.copyWith(datasetImportFolder: path),
    );
    _currentUser = user.copyWith(datasetImportFolder: path);
    _logger.info('Updated dataset import folder to: $path');
  }

  Future<void> setCurrentUserDatasetExportFolder(String path) async {
    final user = getUser();
    await UserDatabase.instance.update(
      user.copyWith(datasetExportFolder: path),
    );
    _currentUser = user.copyWith(datasetExportFolder: path);
    _logger.info('Updated dataset export folder to: $path');
  }

  Future<void> setCurrentUserThumbnailFolder(String path) async {
    final user = getUser();
    await UserDatabase.instance.update(
      user.copyWith(thumbnailFolder: path),
    );
    _currentUser = user.copyWith(thumbnailFolder: path);
    _logger.info('Updated thumbnail folder to: $path');
  }

  void clear() {
    _currentUser = null;
  }
}
