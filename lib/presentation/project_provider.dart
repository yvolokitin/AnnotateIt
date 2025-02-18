import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/data/database.dart';
import 'package:your_app/data/project_repository.dart';

final databaseProvider = Provider((ref) => AppDatabase());
final projectRepositoryProvider = Provider((ref) => ProjectRepository(ref.read(databaseProvider)));

final projectCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getProjectCount();
});
