import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectTile extends StatelessWidget {
  final Project project;

  const ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.folder, color: Colors.blue), // You can customize this to use different icons
        title: Text(
          project.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: ${project.type}"),
            Text("Created: ${project.creationDate.toLocal()}"),
            Text("Labels: ${project.labels.take(5).join(', ')}${project.labels.length > 5 ? ', ...' : ''}"),
          ],
        ),
        onTap: () {
          // Handle project click
        },
      ),
    );
  }
}
