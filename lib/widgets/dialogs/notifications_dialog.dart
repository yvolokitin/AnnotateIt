import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/notification.dart' as NotificationModel;
import '../../data/notification_database.dart';

class NotificationsDialog extends StatefulWidget {
  const NotificationsDialog({super.key});

  @override
  NotificationsDialogState createState() => NotificationsDialogState();
}

class NotificationsDialogState extends State<NotificationsDialog> {
  static const int _pageSize = 20;
  int _currentPage = 0;
  List<NotificationModel.Notification> _notifications = [];
  int _totalCount = 0;
  bool _isLoading = false;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await NotificationDatabase.instance.getAll(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        isRead: _showUnreadOnly ? false : null,
      );

      final totalCount = await NotificationDatabase.instance.getCount(
        isRead: _showUnreadOnly ? false : null,
      );

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _totalCount = totalCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await NotificationDatabase.instance.markAsRead(id);
      _loadNotifications(); // Refresh the list
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationDatabase.instance.markAllAsRead();
      _loadNotifications(); // Refresh the list
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await NotificationDatabase.instance.delete(id);
      _loadNotifications(); // Refresh the list
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _deleteAllNotifications() async {
    try {
      await NotificationDatabase.instance.deleteAll();
      _loadNotifications(); // Refresh the list
    } catch (e) {
      // Handle error silently
    }
  }

  void _nextPage() {
    if ((_currentPage + 1) * _pageSize < _totalCount) {
      setState(() {
        _currentPage++;
      });
      _loadNotifications();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _loadNotifications();
    }
  }

  void _toggleShowUnreadOnly() {
    setState(() {
      _showUnreadOnly = !_showUnreadOnly;
      _currentPage = 0; // Reset to first page
    });
    _loadNotifications();
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0x')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth >= 1600;
    final isTablet = screenWidth >= 900 && screenWidth < 1600;

    final dialogWidth = screenWidth * (isLargeScreen ? 0.8 : isTablet ? 0.9 : 0.95);
    final dialogHeight = screenHeight * (isLargeScreen ? 0.8 : isTablet ? 0.85 : 0.9);

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                  const Spacer(),
                  // Filter toggle
                  TextButton.icon(
                    onPressed: _toggleShowUnreadOnly,
                    icon: Icon(
                      _showUnreadOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    label: Text(
                      _showUnreadOnly ? 'Show All' : 'Unread Only',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mark all as read
                  TextButton.icon(
                    onPressed: _notifications.any((n) => !n.isRead) ? _markAllAsRead : null,
                    icon: const Icon(Icons.done_all, color: Colors.white70, size: 18),
                    label: const Text(
                      'Mark All Read',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete all
                  TextButton.icon(
                    onPressed: _notifications.isNotEmpty ? _deleteAllNotifications : null,
                    icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 18),
                    label: const Text(
                      'Delete All',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _showUnreadOnly ? 'No unread notifications' : 'No notifications',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                  fontFamily: 'CascadiaCode',
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
            ),

            // Pagination
            if (_totalCount > _pageSize)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${_currentPage * _pageSize + 1}-${(_currentPage + 1) * _pageSize > _totalCount ? _totalCount : (_currentPage + 1) * _pageSize} of $_totalCount',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'CascadiaCode',
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                        ),
                        Text(
                          'Page ${_currentPage + 1} of ${(_totalCount / _pageSize).ceil()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'CascadiaCode',
                          ),
                        ),
                        IconButton(
                          onPressed: (_currentPage + 1) * _pageSize < _totalCount ? _nextPage : null,
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel.Notification notification) {
    final backgroundColor = _parseColor(notification.backgroundColor);
    final textColor = _parseColor(notification.textColor);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.isRead ? Colors.grey[800] : Colors.red[900],
      child: InkWell(
        onTap: !notification.isRead ? () => _markAsRead(notification.id!) : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Type indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: backgroundColor, width: 1),
                        ),
                        child: Text(
                          notification.type.toUpperCase(),
                          style: TextStyle(
                            color: backgroundColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'CascadiaCode',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        dateFormat.format(notification.createdAt),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                if (!notification.isRead)
                  IconButton(
                    onPressed: () => _markAsRead(notification.id!),
                    icon: const Icon(Icons.mark_email_read, color: Colors.blue, size: 18),
                    tooltip: 'Mark as read',
                  ),
                IconButton(
                  onPressed: () => _deleteNotification(notification.id!),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}