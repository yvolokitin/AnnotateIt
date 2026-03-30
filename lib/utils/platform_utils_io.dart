import 'dart:io' show Platform;

/// Native implementation: delegates to dart:io Platform.
class PlatformUtils {
  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isLinux => Platform.isLinux;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isWeb => false;
  static String get pathSeparator => Platform.pathSeparator;
  static int get numberOfProcessors => Platform.numberOfProcessors;
  static String get operatingSystem => Platform.operatingSystem;
}
