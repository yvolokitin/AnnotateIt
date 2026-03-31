import 'package:flutter/foundation.dart';
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

  Widget _buildNotificationBadge({required double iconSize}) {
    return Stack(
      children: [
        IconButton(
          onPressed: _showNotifications,
          icon: Icon(
            Icons.notifications_none_rounded,
            size: iconSize,
            color: Colors.white.withValues(alpha: 0.55),
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
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                _unreadNotificationCount > 99
                    ? '99+'
                    : _unreadNotificationCount.toString(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 800;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Thin gradient accent strip
        Container(
          height: 3,
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
        ),

        // Dark header bar
        Container(
          height: isCompact ? 48 : 52,
          color: AppColors.darkRail,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
          child: Row(
            children: [
              // Logo + wordmark together
              _buildBranding(isCompact: isCompact, screenWidth: screenWidth),

              const Spacer(),

              // Exported datasets button (desktop only)
              if (!isCompact)
                _HeaderIconButton(
                  icon: Icons.folder_zip_outlined,
                  tooltip: 'Exported datasets',
                  onPressed: _showExportedDatasetsDialog,
                ),

              const SizedBox(width: 2),

              // Notifications
              _buildNotificationBadge(iconSize: 20),

              // Debug badge
              if (kDebugMode) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.accentOrange.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'DEV',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.accentOrange.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBranding({
    required bool isCompact,
    required double screenWidth,
  }) {
    final iconSize = isCompact ? 26.0 : 30.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon with gradient glow ring
        Container(
          width: iconSize + 4,
          height: iconSize + 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(1.5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.5),
            child: Image.asset(
              'assets/icons/annotateit.jpg',
              height: iconSize,
              width: iconSize,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Wordmark
        Text(
          screenWidth > 1600 ? 'AnnotateIt' : 'AnnotateIt',
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),

        // Subtitle on very wide screens
        if (screenWidth > 1600) ...[
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 16,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(width: 8),
          Text(
            'Vision Annotations',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
