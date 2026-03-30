/// Web stub: all platform checks return false, path separator defaults to '/'.
class PlatformUtils {
  static bool get isWindows => false;
  static bool get isMacOS => false;
  static bool get isLinux => false;
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isDesktop => false;
  static bool get isMobile => false;
  static bool get isWeb => true;
  static String get pathSeparator => '/';
  static int get numberOfProcessors => 1;
  static String get operatingSystem => 'web';
}
