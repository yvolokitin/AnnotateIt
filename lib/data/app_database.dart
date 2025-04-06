
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

enum MediaType { image, video }

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get lastName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get iconPath => text().nullable()();
  TextColumn get datasetsFolderPath => text().nullable()();
  TextColumn get thumbnailsFolderPath => text().nullable()();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
}

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get ownerId => integer()();
}

class Datasets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get projectId => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get description => text().nullable()();
}

class MediaItems extends Table {
  TextColumn get id => text().nullable().customConstraint('UNIQUE')();
  IntColumn get datasetId => integer()();
  TextColumn get filePath => text()();
  IntColumn get type => integer()(); // 0=image, 1=video

  DateTimeColumn get uploadDate => dateTime()();
  TextColumn get owner => text()();
  TextColumn get lastAnnotator => text().nullable()();
  DateTimeColumn get lastAnnotatedDate => dateTime().nullable()();
  IntColumn get numberOfFrames => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, Projects, Datasets, MediaItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Users
  Future<List<User>> getAllUsers() => select(users).get();
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);
  Future<bool> updateUser(User user) => update(users).replace(user);
  Future<int> deleteUser(int id) => (delete(users)..where((u) => u.id.equals(id))).go();

  // Projects
  Future<List<Project>> getAllProjects() => select(projects).get();
  Future<int> insertProject(ProjectsCompanion project) => into(projects).insert(project);
  Future<bool> updateProject(Project project) => update(projects).replace(project);
  Future<int> deleteProject(int id) => (delete(projects)..where((p) => p.id.equals(id))).go();

  // Datasets
  Future<List<Dataset>> getAllDatasets() => select(datasets).get();
  Future<int> insertDataset(DatasetsCompanion dataset) => into(datasets).insert(dataset);
  Future<bool> updateDataset(Dataset dataset) => update(datasets).replace(dataset);
  Future<int> deleteDataset(int id) => (delete(datasets)..where((d) => d.id.equals(id))).go();

  // MediaItems
  Future<List<MediaItem>> getAllMediaItems() => select(mediaItems).get();
  Future<int> insertMediaItem(MediaItemsCompanion item) => into(mediaItems).insert(item);
  Future<bool> updateMediaItem(MediaItem item) => update(mediaItems).replace(item);
  Future<int> deleteMediaItem(String id) => (delete(mediaItems)..where((m) => m.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.sqlite'));
    return NativeDatabase(file);
  });
}
