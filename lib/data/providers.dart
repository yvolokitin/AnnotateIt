import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final projectsStreamProvider = StreamProvider.autoDispose<List<Project>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchProjects();
});

final datasetsStreamProvider = StreamProvider.autoDispose<List<Dataset>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchDatasets();
});

final mediaItemsStreamProvider = StreamProvider.autoDispose<List<MediaItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchMediaItems();
});