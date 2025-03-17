import 'package:flutter/material.dart';
import '../widgets/project_tile.dart';
import '../data/project_database.dart';
import '../models/project.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = ProjectDatabase.instance.fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Projects")),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No projects found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final project = snapshot.data![index];
                return ProjectTile(project: project);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProject() async {
    final newProject = Project(
      name: "New Project",
      type: "Classification",
      icon: "folder", // Can be an asset or predefined icon name
      creationDate: DateTime.now(),
      labels: ["Label1", "Label2", "Label3"],
    );

    await ProjectDatabase.instance.insertProject(newProject);
    setState(() {
      _projectsFuture = ProjectDatabase.instance.fetchProjects(); // Refresh the list
    });
  }
}
