import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Constants {
  // Toolbar and buttons
  static const double toolbarWidth = 62;
  static const double buttonSize = 48;
  static const double iconSize = 28;
  static const EdgeInsets buttonMargin = EdgeInsets.symmetric(horizontal: 4);
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(4));

  // Colors
  static const Color iconColor = Colors.white70;
  static const Color activeBackgroundColor = Color(0xFF424242);
  static const Color toolbarBackgroundColor = Color(0xFF424242);
  static const Color dividerColor = Colors.white30;

  // Platform-aware annotation UI sizes
  static const double _webHandleSize = 12.0;
  static const double _touchHandleSize = 24.0;
  static const double _webHandleRadius = 15.0;
  static const double _touchHandleRadius = 25.0;
  static const double _webBorderWidth = 4.0;
  static const double _touchBorderWidth = 5.0;

  static double get handleSize =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.windows
          ? _webHandleSize
          : _touchHandleSize;

  static double get handleRadius =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.windows
          ? _webHandleRadius
          : _touchHandleRadius;

  static double get annotationBorderWidth =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.windows
          ? _webBorderWidth
          : _touchBorderWidth;
}
