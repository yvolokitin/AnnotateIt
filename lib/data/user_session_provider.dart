import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'providers.dart';

// Provider to hold the current user
final currentUserProvider = StateProvider<User?>((ref) => null);
final currentUserIdProvider = StateProvider<int>((ref) => 0);

// Provider to stream all available users
final allUsersProvider = StreamProvider.autoDispose<List<User>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchUsers();
});


final filteredProjectsByUserProvider = StreamProvider.autoDispose<List<Project>>((ref) {
  final db = ref.watch(databaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return db.watchProjectsByOwner(user.id);
});