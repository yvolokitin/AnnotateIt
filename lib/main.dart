import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' show Value;

import 'package:vap/pages/mainmenu.dart';
import 'package:vap/utils/theme.dart';

import 'data/app_database.dart';
import 'data/providers.dart';
import 'data/user_session_provider.dart';

ThemeData themeData = getSystemTheme();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );

  runApp(const ProviderScope(child: AnnotateItApp()));
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserSession(context);
    });
  }

  Future<void> _initializeUserSession(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final db = container.read(databaseProvider);
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool('orphanedProjectsMigration') ?? false;

    final users = await db.getAllUsers();

    if (users.isEmpty) {
      final userId = await db.insertUser(UsersCompanion(
        name: const Value("Captain Annotator"),
        email: const Value("captain@labelship.local"),
      ));

      final defaultUser =
          (await db.getAllUsers()).firstWhere((u) => u.id == userId);
      container.read(currentUserProvider.notifier).state = defaultUser;
      container.read(currentUserIdProvider.notifier).state = defaultUser.id;

      if (!migrated) {
        final orphanedProjects = await db.getAllProjects();
        for (final project in orphanedProjects) {
          if (project.ownerId == 0) {
            final updated = project.copyWith(ownerId: defaultUser.id);
            await db.updateProject(updated);
          }
        }
        await prefs.setBool('orphanedProjectsMigration', true);
      }
    } else {
      final currentUser = users.first;
      container.read(currentUserProvider.notifier).state = currentUser;
      container.read(currentUserIdProvider.notifier).state = currentUser.id;

      if (!migrated) {
        final orphanedProjects = await db.getAllProjects();
        for (final project in orphanedProjects) {
          if (project.ownerId == 0) {
            final updated = project.copyWith(ownerId: currentUser.id);
            await db.updateProject(updated);
          }
        }
        await prefs.setBool('orphanedProjectsMigration', true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Annot@It",
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const MainPage(),
    );
  }
}
