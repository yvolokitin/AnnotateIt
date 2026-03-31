import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'platform_utils.dart';

final _log = Logger('PermissionGuard');

/// iOS / Android permission kind used by the app.
enum AppPermission {
  camera,
  photos,
  microphone,
  storage,
}

/// Result of a permission check, including a user-friendly message.
class PermissionCheckResult {
  final AppPermission permission;
  final bool granted;
  final String message;
  final bool canOpenSettings;

  const PermissionCheckResult({
    required this.permission,
    required this.granted,
    required this.message,
    this.canOpenSettings = false,
  });

  @override
  String toString() =>
      'PermissionCheckResult(${permission.name}, '
      'granted=$granted, msg="$message")';
}

/// Utility for checking and requesting permissions with
/// user-friendly error messages.
///
/// On non-mobile platforms (Windows, macOS, Linux, Web), all
/// permission checks return granted — platform-level permissions
/// are handled outside Flutter.
class PermissionGuard {
  /// Check whether [permission] is currently granted.
  /// Does NOT trigger a system prompt.
  static Future<PermissionCheckResult> check(AppPermission permission) async {
    if (!_isMobilePlatform()) {
      return PermissionCheckResult(
        permission: permission,
        granted: true,
        message: 'Permissions are managed by the OS on this platform.',
      );
    }

    final status = await _permissionFor(permission).status;
    return _buildResult(permission, status);
  }

  /// Request [permission] from the user. Shows the system dialog
  /// if not yet determined. Returns the updated status.
  static Future<PermissionCheckResult> request(
    AppPermission permission,
  ) async {
    if (!_isMobilePlatform()) {
      return PermissionCheckResult(
        permission: permission,
        granted: true,
        message: 'Permissions are managed by the OS on this platform.',
      );
    }

    final status = await _permissionFor(permission).request();
    _log.fine('${permission.name} permission: ${status.name}');
    return _buildResult(permission, status);
  }

  /// Request multiple permissions at once. Returns a map of results.
  static Future<Map<AppPermission, PermissionCheckResult>> requestAll(
    List<AppPermission> permissions,
  ) async {
    final results = <AppPermission, PermissionCheckResult>{};
    for (final p in permissions) {
      results[p] = await request(p);
    }
    return results;
  }

  /// Show a dialog explaining why the permission is needed and
  /// offering to open Settings. Returns `true` if the user tapped
  /// "Open Settings".
  static Future<bool> showDeniedDialog(
    BuildContext context,
    PermissionCheckResult result,
  ) async {
    if (result.granted) return false;

    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_titleFor(result.permission)),
        content: Text(result.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          if (result.canOpenSettings)
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );

    if (shouldOpen == true) {
      await openAppSettings();
      return true;
    }
    return false;
  }

  /// Check all common permissions and return any that are denied.
  static Future<List<PermissionCheckResult>> auditAll() async {
    final all = [
      AppPermission.camera,
      AppPermission.photos,
      AppPermission.microphone,
    ];

    final results = <PermissionCheckResult>[];
    for (final p in all) {
      final result = await check(p);
      if (!result.granted) results.add(result);
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  static Permission _permissionFor(AppPermission p) {
    switch (p) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.photos:
        return Permission.photos;
      case AppPermission.microphone:
        return Permission.microphone;
      case AppPermission.storage:
        return Permission.storage;
    }
  }

  static PermissionCheckResult _buildResult(
    AppPermission permission,
    PermissionStatus status,
  ) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return PermissionCheckResult(
          permission: permission,
          granted: true,
          message: '${_labelFor(permission)} access is granted.',
        );
      case PermissionStatus.denied:
        return PermissionCheckResult(
          permission: permission,
          granted: false,
          message:
              '${_labelFor(permission)} access is required. '
              'Please grant permission when prompted.',
        );
      case PermissionStatus.permanentlyDenied:
        return PermissionCheckResult(
          permission: permission,
          granted: false,
          canOpenSettings: true,
          message:
              '${_labelFor(permission)} access was denied. '
              'Open Settings to enable it manually.',
        );
      case PermissionStatus.restricted:
        return PermissionCheckResult(
          permission: permission,
          granted: false,
          message:
              '${_labelFor(permission)} access is restricted by '
              'device policy (parental controls, MDM, etc.).',
        );
      case PermissionStatus.provisional:
        return PermissionCheckResult(
          permission: permission,
          granted: true,
          message: '${_labelFor(permission)} access is provisionally granted.',
        );
    }
  }

  static String _labelFor(AppPermission p) {
    switch (p) {
      case AppPermission.camera:
        return 'Camera';
      case AppPermission.photos:
        return 'Photo Library';
      case AppPermission.microphone:
        return 'Microphone';
      case AppPermission.storage:
        return 'Storage';
    }
  }

  static String _titleFor(AppPermission p) {
    switch (p) {
      case AppPermission.camera:
        return 'Camera Access Needed';
      case AppPermission.photos:
        return 'Photo Library Access Needed';
      case AppPermission.microphone:
        return 'Microphone Access Needed';
      case AppPermission.storage:
        return 'Storage Access Needed';
    }
  }

  static bool _isMobilePlatform() {
    if (PlatformUtils.isWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }
}
