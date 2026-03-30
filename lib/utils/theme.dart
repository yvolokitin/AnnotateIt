import "package:flutter/material.dart";

/// Palette derived from the app icon's purple → red → orange gradient.
class AppColors {
  AppColors._();

  // Gradient stops
  static const gradientStart  = Color(0xFF9B30C0); // purple
  static const gradientMid    = Color(0xFFE04444); // warm red
  static const gradientEnd    = Color(0xFFF5A623); // amber/orange

  // Accents
  static const accent         = Color(0xFFE04444); // primary warm red
  static const accentPurple   = Color(0xFFB05CE6); // purple highlight
  static const accentOrange   = Color(0xFFF0943A); // orange highlight

  // Dark-theme surfaces (warm undertone)
  static const darkBg         = Color(0xFF0F1119);
  static const darkSurface    = Color(0xFF1A1F2C);
  static const darkCard       = Color(0xFF1E2332);
  static const darkCardHover  = Color(0xFF262D3E);
  static const darkRail       = Color(0xFF151922);

  static const headerGradient = LinearGradient(
    colors: [gradientStart, gradientMid, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

TextStyle getTextStyle({
  required double fontSize,
  Color color = Colors.black,
  FontWeight fontWeight = FontWeight.w300,
}) {
  return TextStyle(
    fontWeight: fontWeight,
    fontSize: fontSize,
    color: color,
    height: 1.3,
  );
}

TextTheme getTextTheme(Color textColor, Color labelColor) {
  return TextTheme(
    titleLarge: getTextStyle(fontSize: 30, color: textColor, fontWeight: FontWeight.bold)
        .copyWith(letterSpacing: -0.8),
    titleMedium: getTextStyle(fontSize: 25, color: textColor, fontWeight: FontWeight.bold)
        .copyWith(letterSpacing: -0.5),
    headlineMedium: getTextStyle(fontSize: 22, color: textColor)
        .copyWith(letterSpacing: -0.3),
    headlineSmall: getTextStyle(fontSize: 18, color: textColor)
        .copyWith(letterSpacing: -0.3),
    labelLarge: getTextStyle(fontSize: 18, color: labelColor),
    labelMedium: getTextStyle(fontSize: 16, color: labelColor),
    labelSmall: getTextStyle(fontSize: 14, color: labelColor),
    bodyLarge: getTextStyle(fontSize: 16, color: textColor),
    bodyMedium: getTextStyle(fontSize: 14, color: textColor),
    bodySmall: getTextStyle(fontSize: 12, color: textColor),
  );
}

ThemeData createTheme({
  required Brightness brightness,
  required Color backgroundColor,
  required Color surfaceColor,
  required Color onBackgroundColor,
  required Color onSurfaceColor,
}) {
  return ThemeData(
    useMaterial3: false,
    brightness: brightness,
    shadowColor: (brightness == Brightness.light ? Colors.grey : const Color(0xFF2C2C2C))
        .withOpacity(0.5),
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accentOrange,
      onSecondary: Colors.white,
      tertiary: AppColors.accentPurple,
      error: const Color(0xFFEF5350),
      onError: Colors.white,
      background: backgroundColor,
      onBackground: onBackgroundColor,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      surfaceVariant: brightness == Brightness.light
          ? const Color(0xFFA6A6A6)
          : const Color(0xFF707070),
      onSurfaceVariant: onSurfaceColor,
    ),
    textTheme: getTextTheme(onBackgroundColor, Colors.white),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: onSurfaceColor.withOpacity(0.2)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: onSurfaceColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: onSurfaceColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: AppColors.darkCard,
      elevation: 0,
    ),
  );
}

ThemeData lightTheme = createTheme(
  brightness: Brightness.light,
  backgroundColor: const Color(0xFFF8F8FA),
  surfaceColor: const Color(0xFFE8E8EC),
  onBackgroundColor: const Color(0xFF2A2A2A),
  onSurfaceColor: const Color(0xFF2A2A2A),
);

ThemeData darkTheme = createTheme(
  brightness: Brightness.dark,
  backgroundColor: AppColors.darkBg,
  surfaceColor: AppColors.darkSurface,
  onBackgroundColor: Colors.white,
  onSurfaceColor: Colors.white,
);

bool useDarkTheme = true;

ThemeData getSystemTheme() => useDarkTheme ? darkTheme : lightTheme;

final Map<String, ThemeData> themeRegistry = {
  "light": lightTheme,
  "dark": darkTheme,
};

void switchTheme(bool isDarkMode) {
  useDarkTheme = isDarkMode;
}


extension AppColorSchemeExt on ColorScheme {
  Color get muted => onSurface.withOpacity(0.55);

  Color get info => brightness == Brightness.light
      ? const Color(0xFF1E88E5)
      : const Color(0xFF64B5F6);

  Color get success => brightness == Brightness.light
      ? const Color(0xFF2E7D32)
      : const Color(0xFF81C784);

  Color get warning => brightness == Brightness.light
      ? const Color(0xFFF9A825)
      : const Color(0xFFFFE082);

  Color get purple => brightness == Brightness.light
      ? const Color(0xFF8E24AA)
      : const Color(0xFFBA68C8);
}
