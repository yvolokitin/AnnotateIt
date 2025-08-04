import 'package:flutter/material.dart';

import '../models/notification.dart' as NotificationModel;
import '../data/notification_database.dart';

class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.orangeAccent,
    Color textColor = Colors.black,
  }) {
    // Save notification to database
    _saveNotificationToDatabase(message, backgroundColor, textColor);

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontFamily: 'CascadiaCode',
          fontSize: 16,
        ),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static Future<void> _saveNotificationToDatabase(
    String message,
    Color backgroundColor,
    Color textColor,
  ) async {
    try {
      final notification = NotificationModel.Notification(
        message: message,
        type: _getNotificationType(backgroundColor),
        backgroundColor: _colorToHex(backgroundColor),
        textColor: _colorToHex(textColor),
        createdAt: DateTime.now(),
      );

      await NotificationDatabase.instance.create(notification);
    } catch (e) {
      // Silently fail to avoid recursive notification issues
      print('Failed to save notification to database: $e');
    }
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static String _getNotificationType(Color backgroundColor) {
    if (backgroundColor == Colors.red || backgroundColor == Colors.redAccent) {
      return 'error';
    } else if (backgroundColor == Colors.green || backgroundColor == Colors.greenAccent) {
      return 'success';
    } else if (backgroundColor == Colors.yellow || backgroundColor == Colors.yellowAccent) {
      return 'warning';
    } else {
      return 'info';
    }
  }
}
