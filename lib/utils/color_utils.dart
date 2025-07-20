import 'dart:math';
import 'package:flutter/material.dart';

/// Predefined colors (must match ColorPickerDialog.basicColors)
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

/// Generates a color for a label by index. Falls back to random if index exceeds basicColors.
String generateColorByIndex(int index) {
  if (index < basicColors.length) {
    return _toHex(basicColors[index]);
  } else {
    return _generateRandomColor();
  }
}

/// Generates a random HEX color string.
String _generateRandomColor() {
  final random = Random();
  return '#${(random.nextInt(0xFFFFFF) + 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
}

/// Converts a [Color] to HEX string.
String _toHex(Color color) {
  return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}
