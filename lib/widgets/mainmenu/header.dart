import 'package:flutter/material.dart';

import '../../data/notification_database.dart';
import '../dialogs/notifications_dialog.dart';

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
    // Refresh notification count after dialog is closed
    _loadUnreadNotificationCount();
  }

  double _getHeaderHeight(double width) {
    if (width >= 1600) return 88; // large screens
    if (width >= 1200) return 72; // medium screens
    return 56; // small screens
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = _getHeaderHeight(screenWidth);

    return Container(
      height: headerHeight,
      color: Colors.red,
      // padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (screenWidth>1600)
            const SizedBox(width: 20),

          Container(
            width: 71,
            height: headerHeight,
            padding: EdgeInsets.all(screenWidth>1600 ? 2 : 10),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            child: Image.asset(
              'assets/logo/annotateit_white.png',
              height: headerHeight,
            ),
          ),

          const Spacer(),
          
          // Title text positioned on the right
          Container(
            height: headerHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              screenWidth>1600 ? "AnnotateIt - Vision Annotations" : 'AnnotateIt',
              style: TextStyle(
                fontSize: screenWidth>1600 ? 30 : (screenWidth>1200 ? 24 : 20),
                fontWeight: FontWeight.bold,
                fontFamily: 'CascadiaCode',
                color: Colors.white,
              ),
            ),
          ),
          
          // Notification icon with ring indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                IconButton(
                  onPressed: _showNotifications,
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: screenWidth > 1200 ? 28 : 24,
                    color: Colors.white,
                  ),
                  tooltip: 'Notifications',
                ),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
