import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:logging/logging.dart';

import "pages/mainmenu.dart";
import "utils/theme.dart";

// Import FFI for SQLite
import 'data/database_initializer.dart';

import 'data/user_database.dart';
import 'session/user_session.dart';

import "data/dataset_database.dart";
import "data/annotation_database.dart";
import "data/project_database.dart";
import "data/labels_database.dart";

import 'gen_l10n/app_localizations.dart';

ThemeData themeData = getSystemTheme();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database for desktop (Windows, macOS, Linux)
  await initializeDatabase();

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

  // Static method to access the app state from anywhere
  static AnnotateItAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<AnnotateItAppState>();
  }

  // Static reference to the app state
  static AnnotateItAppState? instance;

  @override
  AnnotateItAppState createState() => AnnotateItAppState();
}

class AnnotateItAppState extends State<AnnotateItApp> {
  ThemeData theme = getSystemTheme();
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    AnnotateItApp.instance = this;
  }

  @override
  void dispose() {
    if (AnnotateItApp.instance == this) {
      AnnotateItApp.instance = null;
    }
    super.dispose();
  }

  void updateTheme(ThemeData theme) {
    setState(() {
      this.theme = theme;
    });
    themeData = theme;
  }
  
  // Method to update the app's locale
  void updateLocale() {
    final userLanguage = UserSession.instance.isInitialized 
        ? UserSession.instance.getUser().language 
        : null;
        
    if (userLanguage != null && userLanguage.isNotEmpty) {
      setState(() {
        // Explicitly set the locale to the user's language preference
        _locale = Locale(userLanguage);
      });
      print('App locale updated to: $userLanguage');
    } else {
      setState(() {
        // If no language preference, reset locale to use system default
        _locale = null;
      });
      print('App locale reset to system default');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Annot@It",
      theme: theme,

      home: SafeArea(
        child: Container(
          color: Colors.black,
          child: MainPage(),
        ),
      ),

      // Localization setup
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      // Use explicit locale if set, otherwise use resolution callback
      locale: _locale,

      // Use user's preferred language if available, otherwise use system locale with fallback to English
      localeResolutionCallback: (locale, supportedLocales) {
        // First try to use the user's preferred language from settings
        final userLanguage = UserSession.instance.isInitialized 
            ? UserSession.instance.getUser().language 
            : null;
            
        if (userLanguage != null && userLanguage.isNotEmpty) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == userLanguage) {
              return supportedLocale;
            }
          }
        }
        
        // If user language preference is not set or not supported, try system locale
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        
        // Default to English
        return const Locale('en');
      },
    );
  }
}
