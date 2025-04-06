import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vap/data/app_database.dart';
import 'package:vap/data/providers.dart';
import 'package:vap/data/user_session_provider.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> with SingleTickerProviderStateMixin {
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
    final db = ref.read(databaseProvider); // Access database
    final user = ref.read(currentUserProvider); // Access current user
    final defaultPath = _getDefaultStoragePath();

    if (user != null && ((user.datasetsFolderPath ?? '').isEmpty || (user.thumbnailsFolderPath ?? '').isEmpty)) {
      final updatedCompanion = UsersCompanion(
        id: drift.Value(user.id), // Fix: Wrapping the id in Value() for drift's expected input
        datasetsFolderPath: drift.Value(
          (user.datasetsFolderPath ?? '').isEmpty
              ? '$defaultPath/datasets'
              : user.datasetsFolderPath!,
        ),
        thumbnailsFolderPath: drift.Value(
          (user.thumbnailsFolderPath ?? '').isEmpty
              ? '$defaultPath/thumbnails'
              : user.thumbnailsFolderPath!,
        ),
      );

      await db.updateUser(updatedCompanion); // Fix: Updating user
      final refreshed = await db.getAllUsers().then((users) => users.firstWhere((u) => u.id == user.id));
      ref.read(currentUserProvider.notifier).state = refreshed;
      _user = refreshed;
    } else {
      _user = user; // No changes needed, just assigning user
    }

    setState(() {
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
      await ref.read(databaseProvider).updateUser(_user!);
      ref.read(currentUserProvider.notifier).state = _user!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget userProfileCard(User? user) {
    if (user == null) return const Text("No user selected");
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(user.email ?? "no email", style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                const Text("🧽 Role: Captain", style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bigScreen = screenWidth >= 1600;
    final usersAsync = ref.watch(allUsersProvider);
    final currentUser = ref.watch(currentUserProvider);

    Widget userDropdown = usersAsync.when(
      data: (users) {
        return DropdownButton<User>(
          value: currentUser,
          items: users.map((user) {
            return DropdownMenuItem(
              value: user,
              child: Text(user.name),
            );
          }).toList(),
          onChanged: (selected) {
            if (selected != null) {
              ref.read(currentUserProvider.notifier).state = selected;
            }
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );

    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (screenWidth >= 1600)
              Container(
                height: 95,
                width: double.infinity,
                color: const Color(0xFF11191F),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: userProfileCard(currentUser),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: userDropdown,
                    ),
                  ],
                ),
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
                        Tab(child: Row(children: [if (bigScreen) Icon(Icons.person_outline), if (bigScreen) SizedBox(width: 8), const Text('Profile')])),
                        Tab(child: Row(children: [if (bigScreen) Icon(Icons.folder_open), if (bigScreen) SizedBox(width: 8), const Text('Storage')])),
                        Tab(child: Row(children: [if (bigScreen) Icon(Icons.settings_outlined), if (bigScreen) SizedBox(width: 8), const Text('Settings')])),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          AccountProfile(
                            user: _user!,
                            isEditing: _isEditingProfile,
                            onToggleEdit: () => setState(() => _isEditingProfile = !_isEditingProfile),
                            onUserChange: (updated) => setState(() {
                              _user = updated;
                              _updateUser();
                            }),
                          ),
                          AccountStorage(
                            user: _user!,
                            isEditing: _isEditingStorage,
                            onToggleEdit: () => setState(() => _isEditingStorage = !_isEditingStorage),
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
