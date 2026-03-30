import 'package:flutter/material.dart';

import '../../data/notification_database.dart';
import '../../utils/theme.dart';
import '../dialogs/notifications_dialog.dart';
import 'exported_datasets_dialog.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  AppHeaderState createState() => AppHeaderState();
}

class AppHeaderState extends State<AppHeader> {
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final count = await NotificationDatabase.instance.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _showNotifications() async {
    await showDialog(
      context: context,
      builder: (context) => const NotificationsDialog(),
    );
    _loadUnreadNotificationCount();
  }

  void _showExportedDatasetsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const ExportedDatasetsDialog(),
    );
  }

  double _getHeaderHeight(double width) {
    if (width >= 1600) return 72;
    if (width >= 1200) return 64;
    return 56;
  }

  Widget _buildNotificationBadge({required double iconSize}) {
    return Stack(
      children: [
        IconButton(
          onPressed: _showNotifications,
          icon: Icon(
            Icons.notifications_none_rounded,
            size: iconSize,
            color: Colors.white.withOpacity(0.9),
          ),
          tooltip: 'Notifications',
        ),
        if (_unreadNotificationCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                _unreadNotificationCount > 99
                    ? '99+'
                    : _unreadNotificationCount.toString(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = _getHeaderHeight(screenWidth);

    return Container(
      height: headerHeight,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: screenWidth < 800
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _showExportedDatasetsDialog,
                  icon: Icon(
                    Icons.folder_zip_outlined,
                    size: 22,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/icons/annotateit.jpg',
                            height: 28,
                            width: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AnnotateIt',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: _buildNotificationBadge(iconSize: 22),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: screenWidth > 1600 ? 20 : 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/icons/annotateit.jpg',
                    height: headerHeight - 20,
                    width: headerHeight - 20,
                  ),
                ),

                const Spacer(),

                Container(
                  height: headerHeight,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 16 : 8),
                  child: Text(
                    screenWidth > 1600
                        ? 'AnnotateIt — Vision Annotations'
                        : 'AnnotateIt',
                    style: TextStyle(
                      fontSize: screenWidth > 1600 ? 26 : (screenWidth > 1200 ? 22 : 18),
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildNotificationBadge(
                    iconSize: screenWidth > 1200 ? 26 : 22,
                  ),
                ),

                SizedBox(width: screenWidth > 500 ? 12 : 4),
              ],
            ),
    );
  }
}
