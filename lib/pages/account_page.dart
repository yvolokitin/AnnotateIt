import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../data/user_database.dart';
import '../models/user.dart';
import '../session/user_session.dart';

import '../widgets/account/user_profile.dart';
import '../widgets/account/account_storage.dart';
import '../widgets/account/application_settings.dart';

import '../../gen_l10n/app_localizations.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _user;
  bool _loading = true;
  final _logger = Logger('AccountPage');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    var user = await UserDatabase.instance.getUser();

    final importPath = await UserSession.instance.getCurrentUserDatasetImportFolder();
    final exportPath = await UserSession.instance.getCurrentUserDatasetExportFolder();
    final thumbnailPath = await UserSession.instance.getCurrentUserThumbnailFolder();

    if (user != null &&
        (user.datasetImportFolder.isEmpty ||
         user.datasetExportFolder.isEmpty ||
         user.thumbnailFolder.isEmpty)) {
      user = user.copyWith(
        datasetImportFolder: user.datasetImportFolder.isEmpty ? importPath : user.datasetImportFolder,
        datasetExportFolder: user.datasetExportFolder.isEmpty ? exportPath : user.datasetExportFolder,
        thumbnailFolder: user.thumbnailFolder.isEmpty ? thumbnailPath : user.thumbnailFolder,
      );
      await UserDatabase.instance.update(user);
      _logger.info('Updated user with default import/export/thumbnail folders.');
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
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_loading) {
      return const Scaffold(
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
                child: const Text(""),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (screenWidth >= 1600) ? 60.0 : 10.0,
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.red,
                      indicatorWeight: 3.0,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontSize: 22, fontFamily: 'CascadiaCode'),
                      unselectedLabelStyle: const TextStyle(fontSize: 22, fontFamily: 'CascadiaCode'),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_outline),
                              if (screenWidth > 700) ...[
                                const SizedBox(width: 8),
                                Text(
                                  l10n.accountUser,
                                  style: TextStyle(
                                    fontFamily: 'CascadiaCode',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                              if (screenWidth > 1500)
                                Text(
                                  l10n.accountProfile,
                                  style: TextStyle(
                                    fontFamily: 'CascadiaCode',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_open),
                              if (screenWidth > 700 && screenWidth <= 1500) ...[
                                const SizedBox(width: 8),
                                Text(
                                  l10n.accountStorage,
                                  style: TextStyle(
                                    fontFamily: 'CascadiaCode',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                              if (screenWidth > 1500) ...[
                                const SizedBox(width: 8),
                                Text(
                                  l10n.accountDeviceStorage,
                                  style: TextStyle(
                                    fontFamily: 'CascadiaCode',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.settings),
                              if (screenWidth > 700 && screenWidth <= 1500) ...[
                                const SizedBox(width: 8),
                                Text(
                                  l10n.accountSettings,
                                  style: TextStyle(
                                    fontFamily: 'CascadiaCode',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                              if (screenWidth > 1500) ...[
                                const SizedBox(width: 8),
                                Text(
                                  l10n.accountApplicationSettings,
                                  style: TextStyle(
                                    fontFamily: 'CascadiaCode',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          const UserProfile(),
                          AccountStorage(
                            user: _user!,
                            onUserChange: (updated) => setState(() {
                              _user = updated;
                              _updateUser();
                            }),
                          ),
                          ApplicationSettings(
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