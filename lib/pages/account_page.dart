import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../data/user_database.dart';
import '../models/user.dart';
import '../session/user_session.dart';

import '../widgets/account/user_profile.dart';
import '../widgets/account/account_storage.dart';
import '../widgets/account/application_settings.dart';
import '../widgets/responsive/responsive_layout.dart';

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

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveLayout.builder(
      builder: (context, constraints, screenSize) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header container only for large desktop
                if (screenSize == ScreenSize.largeDesktop)
                  Container(
                    height: 95,
                    width: double.infinity,
                    color: const Color(0xFF11191F),
                    child: const Text(""),
                  ),
                Expanded(
                  child: Padding(
                    padding: ResponsiveLayout.getHorizontalPadding(context),
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
                            _buildResponsiveTab(
                              icon: Icons.person_outline,
                              shortLabel: l10n.accountUser,
                              fullLabel: l10n.accountProfile,
                              screenSize: screenSize,
                            ),
                            _buildResponsiveTab(
                              icon: Icons.folder_open,
                              shortLabel: l10n.accountStorage,
                              fullLabel: l10n.accountDeviceStorage,
                              screenSize: screenSize,
                            ),
                            _buildResponsiveTab(
                              icon: Icons.settings,
                              shortLabel: l10n.accountSettings,
                              fullLabel: l10n.accountApplicationSettings,
                              screenSize: screenSize,
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
                                  // Update the UserSession with the updated user
                                  UserSession.instance.setUser(updated);
                                }),
                              ),
                              ApplicationSettings(
                                user: _user!,
                                onUserChange: (updated) => setState(() {
                                  _user = updated;
                                  _updateUser();
                                  // Update the UserSession with the updated user
                                  UserSession.instance.setUser(updated);
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
      },
    );
  }
  
  /// Helper method to build responsive tabs
  Widget _buildResponsiveTab({
    required IconData icon,
    required String shortLabel,
    required String fullLabel,
    required ScreenSize screenSize,
  }) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          // Show short label for tablet and desktop
          if (screenSize == ScreenSize.tablet || screenSize == ScreenSize.desktop) ...[
            const SizedBox(width: 8),
            Text(
              shortLabel,
              style: const TextStyle(
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
          // Show full label for large desktop
          if (screenSize == ScreenSize.largeDesktop) ...[
            const SizedBox(width: 8),
            Text(
              fullLabel,
              style: const TextStyle(
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}