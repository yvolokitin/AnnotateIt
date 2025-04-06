  import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
  TextColumn get themeMode => text().withDefault(const Constant('dark'))(); // 'light' | 'dark'
  TextColumn get language => text().withDefault(const Constant('en'))();     // 'en' | 'nl' | 'ru'
}

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get icon => text()();
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get lastUpdated => dateTime()();
  TextColumn get labels => text()();
  TextColumn get labelColors => text()();
  TextColumn get defaultDatasetId => text()();
  IntColumn get ownerId => integer().references(Users, #id)();
}

class Datasets extends Table {
  TextColumn get id => text()();
  IntColumn get projectId => integer().references(Projects, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MediaItems extends Table {
  TextColumn get id => text().nullable().customConstraint('UNIQUE')();
  TextColumn get datasetId => text()();
  TextColumn get filePath => text()();

  IntColumn get type => intEnum<MediaType>()();

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

  // === Users ===
  Future<List<User>> getAllUsers() => select(users).get();
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);
  Future<bool> updateUser(User user) => update(users).replace(user);
  Future<int> deleteUser(int id) => (delete(users)..where((u) => u.id.equals(id))).go();
  Stream<List<User>> watchUsers() => select(users).watch();

  // === Projects ===
  Future<int> insertProjectWithDefaultDataset({
    required String name,
    required String type,
    required String icon,
    required int ownerId,
    required String labels,
    required String labelColors,
  }) async {
    final now = DateTime.now();
    final datasetId = const Uuid().v4();

    await into(datasets).insert(DatasetsCompanion(
      id: Value(datasetId),
      name: Value("Default Dataset"),
      projectId: Value(-1), // temporary
      createdAt: Value(now),
    ));

    final projectId = await into(projects).insert(ProjectsCompanion(
      name: Value(name),
      type: Value(type),
      icon: Value(icon),
      creationDate: Value(now),
      lastUpdated: Value(now),
      labels: Value(labels),
      labelColors: Value(labelColors),
      defaultDatasetId: Value(datasetId),
      ownerId: Value(ownerId),
    ));

    await (update(datasets)..where((d) => d.id.equals(datasetId))).write(
      DatasetsCompanion(projectId: Value(projectId)),
    );

    return projectId;
  }

  Future<List<Project>> getAllProjects() => select(projects).get();
  Future<bool> updateProject(Project project) => update(projects).replace(project);
  Future<int> deleteProject(int id) => (delete(projects)..where((p) => p.id.equals(id))).go();
  Future<void> updateProjectIcon(int projectId, String iconPath) async {
    await (update(projects)
      ..where((p) => p.id.equals(projectId)))
      .write(ProjectsCompanion(icon: Value(iconPath)));
  }

  Stream<List<Project>> watchProjects() => select(projects).watch();
  Stream<List<Project>> watchProjectsByOwner(int ownerId) {
    return (select(projects)..where((p) => p.ownerId.equals(ownerId))).watch();
  }

  // === Datasets ===
  Future<List<Dataset>> getAllDatasets() => select(datasets).get();
  Future<int> insertDataset(DatasetsCompanion dataset) => into(datasets).insert(dataset);
  Future<bool> updateDataset(Dataset dataset) => update(datasets).replace(dataset);
  Future<int> deleteDataset(String id) => (delete(datasets)..where((d) => d.id.equals(id))).go();
  Stream<List<Dataset>> watchDatasets() => select(datasets).watch();

  // === MediaItems ===
  Future<List<MediaItem>> getAllMediaItems() => select(mediaItems).get();
  Future<int> insertMediaItem(MediaItemsCompanion item) => into(mediaItems).insert(item);
  Future<bool> updateMediaItem(MediaItem item) => update(mediaItems).replace(item);
  Future<int> deleteMediaItem(String id) => (delete(mediaItems)..where((m) => m.id.equals(id))).go();
  Stream<List<MediaItem>> watchMediaItems() => select(mediaItems).watch();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.sqlite'));
    return NativeDatabase(file);
  });
}
