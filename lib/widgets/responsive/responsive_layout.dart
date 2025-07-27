import 'package:flutter/material.dart';

/// A utility class that provides responsive design functionality
/// with standardized breakpoints and responsive behaviors.
class ResponsiveLayout {
  // Standard breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// Returns true if the current screen width is less than the mobile breakpoint
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Returns true if the current screen width is between the mobile and tablet breakpoints
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  /// Returns true if the current screen width is between the tablet and desktop breakpoints
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint &&
      MediaQuery.of(context).size.width < largeDesktopBreakpoint;

  /// Returns true if the current screen width is greater than the large desktop breakpoint
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktopBreakpoint;

  /// Returns the appropriate value based on the current screen size
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= largeDesktopBreakpoint && largeDesktop != null) {
      return largeDesktop;
    }
    if (width >= desktopBreakpoint && desktop != null) {
      return desktop;
    }
    if (width >= mobileBreakpoint && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// A builder widget that provides the constraints to its builder function
  /// and rebuilds when the screen size changes
  static Widget builder({
    required Widget Function(
      BuildContext context,
      BoxConstraints constraints,
      ScreenSize screenSize,
    ) builder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.of(context).size.width;
        ScreenSize screenSize;

        if (width >= largeDesktopBreakpoint) {
          screenSize = ScreenSize.largeDesktop;
        } else if (width >= desktopBreakpoint) {
          screenSize = ScreenSize.desktop;
        } else if (width >= mobileBreakpoint) {
          screenSize = ScreenSize.tablet;
        } else {
          screenSize = ScreenSize.mobile;
        }

        return builder(context, constraints, screenSize);
      },
    );
  }

  /// Returns a responsive padding based on the screen size
  static EdgeInsets getPadding(BuildContext context) {
    return value<EdgeInsets>(
      context: context,
      mobile: const EdgeInsets.all(8.0),
      tablet: const EdgeInsets.all(16.0),
      desktop: const EdgeInsets.all(24.0),
      largeDesktop: const EdgeInsets.all(32.0),
    );
  }

  /// Returns a responsive horizontal padding based on the screen size
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    return value<EdgeInsets>(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 8.0),
      tablet: const EdgeInsets.symmetric(horizontal: 16.0),
      desktop: const EdgeInsets.symmetric(horizontal: 24.0),
      largeDesktop: const EdgeInsets.symmetric(horizontal: 32.0),
    );
  }
}

/// Enum representing different screen sizes
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// A widget that adapts its child based on the screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.builder(
      builder: (context, constraints, screenSize) {
        switch (screenSize) {
          case ScreenSize.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
          case ScreenSize.desktop:
            return desktop ?? tablet ?? mobile;
          case ScreenSize.tablet:
            return tablet ?? mobile;
          case ScreenSize.mobile:
            return mobile;
        }
      },
    );
  }
}