import 'package:flutter/foundation.dart';

/// Web-safe wrappers for dart:io Platform checks.
///
/// On web, `Platform.isWindows` etc. throw "Unsupported operation".
/// These helpers return false on web and delegate to Platform on native.
///
/// Usage: replace `Platform.isWindows` with `PlatformUtils.isWindows` everywhere.

// Conditional import: real implementation on native, stubs on web
export 'platform_utils_stub.dart' if (dart.library.io) 'platform_utils_io.dart';
