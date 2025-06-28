import 'package:flutter/material.dart';

class ToolbarDivider extends StatelessWidget {
  final bool isCompact;
  
  const ToolbarDivider({
    super.key,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.white30, 
      height: isCompact ? 15 : 30,
    );
  }
}
