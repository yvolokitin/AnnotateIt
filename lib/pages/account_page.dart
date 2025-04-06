import 'dart:io';
import 'package:flutter/material.dart';
import '../data/user_database.dart';

import '../widgets/account_profile.dart';
import '../widgets/account_storage.dart';
import '../widgets/account_settings.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _user;
  bool _loading = true;
  bool _isEditingProfile = false;
  bool _isEditingStorage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    var user = await UserDatabase.instance.getUser();

    final defaultPath = _getDefaultStoragePath();

    if (user != null && (user.datasetFolder.isEmpty || user.thumbnailFolder.isEmpty)) {
      user = user.copyWith(
        datasetFolder: user.datasetFolder.isEmpty ? '$defaultPath/datasets' : user.datasetFolder,
        thumbnailFolder: user.thumbnailFolder.isEmpty ? '$defaultPath/thumbnails' : user.thumbnailFolder,
      );
      await UserDatabase.instance.update(user);
    }

    setState(() {
      _user = user;
      _loading = false;
    });
  }

  String _getDefaultStoragePath() {
    if (Platform.isWindows) {
      return 'C:\\Users\\${Platform.environment['USERNAME']}\\Documents\\AnnotationApp';
    } else if (Platform.isLinux || Platform.isMacOS) {
      return '/home/${Platform.environment['USER']}/AnnotationApp';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return '/storage/emulated/0/AnnotationApp';
    } else {
      return '/AnnotationApp';
    }
  }

  Future<void> _updateUser() async {
    if (_user != null) {
      await UserDatabase.instance.update(_user!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  if (_loading) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  final bigScreen = screenWidth >= 1600;
  
  return Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          // shown only on wide screens
          if (screenWidth >= 1600)
            Container(
              height: 95,
              width: double.infinity,
              color: const Color(0xFF11191F),
              child: Text(""),
              ),
          
          // TabBar and TabBarView below the custom AppBar
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: bigScreen ? 60.0 : 10.0,
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.red,
                    indicatorWeight: 3.0,
                    labelColor: Colors.white, // Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontSize: 22),
                    unselectedLabelStyle: const TextStyle(fontSize: 22),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (bigScreen) Icon(Icons.person_outline),
                            if (bigScreen) SizedBox(width: 8),
                            const Text('Profile'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (bigScreen) Icon(Icons.folder_open),
                            if (bigScreen) SizedBox(width: 8),
                            const Text('Storage'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (bigScreen) Icon(Icons.settings_outlined),
                            if (bigScreen) SizedBox(width: 8),
                            const Text('Settings'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        AccountProfile(
                          user: _user!,
                          isEditing: _isEditingProfile,
                          onToggleEdit: () =>
                              setState(() => _isEditingProfile = !_isEditingProfile),
                          onUserChange: (updated) => setState(() {
                            _user = updated;
                            _updateUser();
                          }),
                        ),
                        AccountStorage(
                          user: _user!,
                          isEditing: _isEditingStorage,
                          onToggleEdit: () =>
                              setState(() => _isEditingStorage = !_isEditingStorage),
                          onUserChange: (updated) => setState(() {
                            _user = updated;
                            _updateUser();
                          }),
                        ),
                        AccountSettings(
                          user: _user!,
                          onUserChange: (updated) => setState(() {
                            _user = updated;
                            _updateUser();
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
