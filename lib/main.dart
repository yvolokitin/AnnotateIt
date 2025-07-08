import "package:vap/pages/mainmenu.dart";
import "package:vap/utils/theme.dart";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import 'package:logging/logging.dart';

// Import FFI for SQLite
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vap/data/database_initializer.dart';

import 'data/user_database.dart';
import 'session/user_session.dart';

import "data/dataset_database.dart";
import "data/annotation_database.dart";
import "data/project_database.dart";
import "data/labels_database.dart";

import 'package:vap/gen_l10n/app_localizations.dart';

ThemeData themeData = getSystemTheme();

void main() async {
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('StackTrace: ${record.stackTrace}');
    }
  });

  // Initialize database for desktop (Windows, macOS, Linux)
  // sqfliteFfiInit(); 
  // databaseFactory = databaseFactoryFfi;
  await initializeDatabase();
  
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the shared database
  final db = await ProjectDatabase.instance.database;

  // Inject it into DatasetDatabase
  DatasetDatabase.instance.setDatabase(db);
  AnnotationDatabase.instance.setDatabase(db);
  LabelsDatabase.instance.setDatabase(db);
  UserDatabase.instance.setDatabase(db);

  // Load the default user into session
  final defaultUser = await UserDatabase.instance.getUser();
  if (defaultUser != null) {
    UserSession.instance.setUser(defaultUser);
  }

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

  void updateTheme(ThemeData theme) {
    setState(() {
      this.theme = theme;
    });
    themeData = theme;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Annot@It",
      theme: theme,
      // home: MainPage(),

      home: Container(
        color: Colors.black,
        child: MainPage(),
      ),

      // Localization setup
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // temporary solution: Hardcode to English
      locale: const Locale('en'),

      // Optional: Use system locale with fallback to English
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('en');
      },
    );
  }
}
