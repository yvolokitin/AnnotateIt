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
  User? user;
  bool loading = true;
  bool error = false;
  String? errorMessage;
  final _logger = Logger('AccountPage');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      var fetchedUser = await UserDatabase.instance.getUser();

      if (fetchedUser != null) {
        try {
          final importPath = await UserSession.instance.getCurrentUserDatasetImportFolder();
          final exportPath = await UserSession.instance.getCurrentUserDatasetExportFolder();
          final thumbnailPath = await UserSession.instance.getCurrentUserThumbnailFolder();

          fetchedUser = fetchedUser.copyWith(
            datasetImportFolder: (fetchedUser.datasetImportFolder?.isEmpty ?? true)
                ? importPath
                : fetchedUser.datasetImportFolder,
            datasetExportFolder: (fetchedUser.datasetExportFolder?.isEmpty ?? true)
                ? exportPath
                : fetchedUser.datasetExportFolder,
            thumbnailFolder: (fetchedUser.thumbnailFolder?.isEmpty ?? true)
                ? thumbnailPath
                : fetchedUser.thumbnailFolder,
          );

          await UserDatabase.instance.update(fetchedUser);
          _logger.info('Updated user with default import/export/thumbnail folders.');
        } catch (e, st) {
          _logger.warning('Failed to load folder paths, using existing values', e, st);
          setState(() {
            errorMessage = '${e.toString()}';
          });
        }
      }

      if (mounted) {
        setState(() {
          user = fetchedUser;
          loading = false;
          error = false;
        });
      }
    } catch (e, st) {
      _logger.severe('Failed to load user data', e, st);
      if (mounted) {
        setState(() {
          loading = false;
          error = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _updateUser() async {
    if (user != null) {
      await UserDatabase.instance.update(user!);
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

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.accountErrorLoadingUser),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = false;
                  });
                  loadUserData();
                },
                child: Text(l10n.accountRetry),
              ),
            ],
          ),
        ),
      );
    }

    return ResponsiveLayout.builder(
      builder: (context, constraints, screenSize) {
        try {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
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
                          if (errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: user == null
                                ? Center(child: Text(l10n.accountErrorLoadingUser))
                                : TabBarView(
                                    controller: _tabController,
                                    children: [
                                      const UserProfile(),
                                      AccountStorage(
                                        user: user!,
                                        onUserChange: (updated) => setState(() {
                                          user = updated;
                                          _updateUser();
                                          UserSession.instance.setUser(updated);
                                        }),
                                      ),
                                      ApplicationSettings(
                                        user: user!,
                                        onUserChange: (updated) => setState(() {
                                          user = updated;
                                          _updateUser();
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
        } catch (e, st) {
          _logger.severe("Error in ResponsiveLayout.builder", e, st);
          return Scaffold(
            body: Center(
              child: Text('Unexpected layout error:\n$e'),
            ),
          );
        }
      },
    );
  }

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
