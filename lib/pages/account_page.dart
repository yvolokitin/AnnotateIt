import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../data/user_database.dart';
import '../models/user.dart';
import '../session/user_session.dart';

import '../widgets/account/user_profile.dart';
import '../widgets/account/account_storage.dart';
import '../widgets/account/account_settings.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _user;
  bool _loading = true;
  bool _isEditingProfile = false;
  bool _isEditingStorage = false;
  final _logger = Logger('AccountPage');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    var user = await UserDatabase.instance.getUser();

    final datasetPath = await UserSession.instance.getCurrentUserDatasetFolder();
    final thumbnailPath = await UserSession.instance.getCurrentUserThumbnailFolder();

    if (user != null && (user.datasetFolder.isEmpty || user.thumbnailFolder.isEmpty)) {
      user = user.copyWith(
        datasetFolder: user.datasetFolder.isEmpty ? datasetPath : user.datasetFolder,
        thumbnailFolder: user.thumbnailFolder.isEmpty ? thumbnailPath : user.thumbnailFolder,
      );
      await UserDatabase.instance.update(user);
      _logger.info('Updated user with default dataset and thumbnail folders.');
    }

    setState(() {
      _user = user;
      _loading = false;
    });
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
            if (screenWidth >= 1600)
              Container(
                height: 95,
                width: double.infinity,
                color: const Color(0xFF11191F),
                child: Text(""),
              ),
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
                      labelColor: Colors.white,
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
                              const Text('User Profile'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (bigScreen) Icon(Icons.folder_open),
                              if (bigScreen) SizedBox(width: 8),
                              const Text('Device Storage'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (bigScreen) Icon(Icons.settings_outlined),
                              if (bigScreen) SizedBox(width: 8),
                              const Text('Application Settings'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          UserProfile(),
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
