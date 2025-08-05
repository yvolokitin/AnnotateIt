import 'dart:io';
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

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
import "data/notification_database.dart";

import 'gen_l10n/app_localizations.dart';
import 'package:window_size/window_size.dart';

ThemeData themeData = getSystemTheme();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logging first
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

  final log = Logger('main');

  try {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        setWindowMinSize(const Size(1200, 700)); // minimum size
        setWindowMaxSize(Size.infinite); //no max limit
      } catch (e) {
        log.warning('Could not set window size: $e');
      }
    }

    // Initialize database for desktop (Windows, macOS, Linux)
    try {
      await initializeDatabase();
      log.info('Database factory initialized successfully');
    } catch (e) {
      log.severe('Failed to initialize database factory: $e');
      // Continue anyway - the app might still work with default settings
    }

    // Initialize the shared database
    Database? db;
    try {
      db = await ProjectDatabase.instance.database;
      log.info('Project database initialized successfully');
    } catch (e) {
      log.severe('Failed to initialize project database: $e');
      // This is critical - we can't continue without a database
      runApp(ErrorApp(error: 'Database initialization failed: $e'));
      return;
    }

    // Inject database into other database instances
    try {
      DatasetDatabase.instance.setDatabase(db);
      AnnotationDatabase.instance.setDatabase(db);
      LabelsDatabase.instance.setDatabase(db);
      UserDatabase.instance.setDatabase(db);
      NotificationDatabase.instance.setDatabase(db);
      log.info('Database instances configured successfully');
    } catch (e) {
      log.severe('Failed to configure database instances: $e');
      runApp(ErrorApp(error: 'Database configuration failed: $e'));
      return;
    }

    // Load the default user into session
    try {
      final defaultUser = await UserDatabase.instance.getUser();
      if (defaultUser != null) {
        UserSession.instance.setUser(defaultUser);
        log.info('Default user loaded into session');
      } else {
        log.info('No default user found');
      }
    } catch (e) {
      log.warning('Could not load default user: $e');
      // Continue without user session - the app can still work
    }

    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    } catch (e) {
      log.warning('Could not set system UI mode: $e');
    }

    runApp(const AnnotateItApp());
  } catch (e, stackTrace) {
    log.severe('Critical error during app initialization: $e', e, stackTrace);
    runApp(ErrorApp(error: 'App initialization failed: $e'));
  }
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

// Error app to display when critical initialization fails
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AnnotateIt - Error",
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'AnnotateIt Failed to Start',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'The application encountered a critical error during initialization and cannot continue.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    error,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please try restarting the application. If the problem persists, contact support.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
