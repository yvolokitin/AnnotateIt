import 'dart:math';
import 'package:flutter/material.dart';

const List<Color> basicColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.cyan,
  Colors.brown,
  Colors.pink,
  Colors.teal,
  Color(0xFF336666),
  Color(0xFF888888),
  Color(0xFFCCCCCC),
  Color(0xFFFFC107),
  Colors.black,
  Colors.white,
];

/// Generates a hex color for a label by index. Falls back to random beyond palette.
String generateColorByIndex(int index) {
  if (index < basicColors.length) {
    return colorToHex(basicColors[index]);
  }
  return generateRandomHexColor();
}

/// Generates a random HEX color string like '#A1B2C3'.
String generateRandomHexColor() {
  final random = Random();
  final r = random.nextInt(200) + 55;
  final g = random.nextInt(200) + 55;
  final b = random.nextInt(200) + 55;
  return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
}

/// Converts a [Color] to a '#RRGGBB' hex string.
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}

/// Parses a '#RRGGBB' or '#AARRGGBB' hex string to a [Color].
Color colorFromHex(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}
