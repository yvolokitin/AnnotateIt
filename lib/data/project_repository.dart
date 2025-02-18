import 'package:your_app/data/database.dart';

class ProjectRepository {
  final AppDatabase db;

  ProjectRepository(this.db);

  Future<int> getProjectCount() {
    return db.getProjectCount();
  }

  Future<void> addProject(String name) async {
    await db.insertProject(Project(name: name, createdAt: DateTime.now()));
  }
}
