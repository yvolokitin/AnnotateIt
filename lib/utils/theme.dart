import "package:flutter/material.dart";

TextStyle getTextStyle({
  required double fontSize,
  Color color = Colors.black,
  FontWeight fontWeight = FontWeight.w300,
}) {
  return TextStyle(
    fontFamily: "CascadiaCode",
    fontStyle: FontStyle.normal,
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
  Color outline = Colors.transparent,
}) {
  return ThemeData(
    useMaterial3: false,
    brightness: brightness,
    shadowColor: (brightness == Brightness.light ? Colors.grey : const Color(0xFF2C2C2C))
        .withOpacity(0.5),
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: const Color(0xFF1095C1),
      onPrimary: Colors.white,
      secondary: const Color(0xFF1095C1),
      onSecondary: Colors.white,
      tertiary: const Color(0xFF5B5B5B),
      error: Colors.red,
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
        side: BorderSide(color: outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 3),
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red, width: 3),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red, width: 3),
      ),
    ),
  );
}

ThemeData lightTheme = createTheme(
  brightness: Brightness.light,
  backgroundColor: Colors.white,
  surfaceColor: const Color(0xFFE2E2E2),
  onBackgroundColor: const Color(0xFF373737),
  onSurfaceColor: const Color(0xFF373737),
  outline: Colors.red,
);

ThemeData darkTheme = createTheme(
  brightness: Brightness.dark,
  backgroundColor: const Color(0xFF11191F),
  surfaceColor: const Color(0xFF293036),
  onBackgroundColor: Colors.white,
  onSurfaceColor: Colors.white,
  outline: Colors.red,
);

bool useDarkTheme = true;

ThemeData getSystemTheme() => useDarkTheme ? darkTheme : lightTheme;

final Map<String, ThemeData> themeRegistry = {
  "light": lightTheme,
  "dark": darkTheme,
};

// Function to switch themes dynamically
void switchTheme(bool isDarkMode) {
  useDarkTheme = isDarkMode;
}


// Semantic color extensions to enrich the palette across the app
extension AppColorSchemeExt on ColorScheme {
  // Muted text/icons for secondary emphasis
  Color get muted => onSurface.withOpacity(0.7);

  // Informational/primary accent (harmonizes with existing blue primary)
  Color get info => brightness == Brightness.light
      ? const Color(0xFF1E88E5) // Blue 600
      : const Color(0xFF64B5F6); // Blue 300

  // Success/positive actions
  Color get success => brightness == Brightness.light
      ? const Color(0xFF2E7D32) // Green 800
      : const Color(0xFF81C784); // Green 300

  // Warning/attention
  Color get warning => brightness == Brightness.light
      ? const Color(0xFFF9A825) // Amber 700
      : const Color(0xFFFFE082); // Amber 200

  // Purple accent (used for AI/pre-label type actions)
  Color get purple => brightness == Brightness.light
      ? const Color(0xFF8E24AA) // Purple 600
      : const Color(0xFFBA68C8); // Purple 300
}