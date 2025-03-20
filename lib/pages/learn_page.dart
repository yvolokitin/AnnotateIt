import "package:flutter/material.dart";
import '../data/project_database.dart';

// Learn Widget
class LearnWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      // Wrap with Column to allow multiple children
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Learn",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await ProjectDatabase.instance.runManualSQLUpdate();
              print("Database updated manually!");
            },
            child: Text("Update DB"),
          ),
        ],
      ),
    );
  }
}
