import "package:vap/pages/mainmenu.dart";
import "package:vap/utils/theme.dart";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

// Import FFI for SQLite
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import "data/dataset_database.dart";
import "data/project_database.dart";

ThemeData themeData = getSystemTheme();

void main() async {
  // Initialize database for desktop (Windows, macOS, Linux)
  sqfliteFfiInit(); 
  databaseFactory = databaseFactoryFfi;
  
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the shared database
  final db = await ProjectDatabase.instance.database;

  // Inject it into DatasetDatabase
  DatasetDatabase.instance.setDatabase(db);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);

  runApp(const AnnotateItApp());
}

class AnnotateItApp extends StatefulWidget {
  const AnnotateItApp({super.key});

  @override
  AnnotateItAppState createState() => AnnotateItAppState();
}

class AnnotateItAppState extends State<AnnotateItApp> {
  ThemeData theme = getSystemTheme();

  // changes the widget state when updating the theme through changing the theme variable to the given theme.
  updateTheme(ThemeData theme) {
    setState(() {this.theme = theme;});
    themeData = theme;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Annot@It",
      theme: theme,
      home: MainPage(),
    );
  }
}
