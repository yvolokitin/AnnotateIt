import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/presentation/project_provider.dart';

class MainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectCount = ref.watch(projectCountProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Projects")),
      body: Center(
        child: projectCount.when(
          data: (count) => Text("Total Projects: $count", style: TextStyle(fontSize: 24)),
          loading: () => CircularProgressIndicator(),
          error: (err, stack) => Text("Error loading data"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(projectRepositoryProvider).addProject("New Project");
          ref.invalidate(projectCountProvider); // Refresh data
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
