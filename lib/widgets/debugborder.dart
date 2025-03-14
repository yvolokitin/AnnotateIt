import 'package:flutter/material.dart';

class DebugBorder extends StatelessWidget {
  final Widget child;

  DebugBorder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 4),
      ),
      child: child,
    );
  }
}