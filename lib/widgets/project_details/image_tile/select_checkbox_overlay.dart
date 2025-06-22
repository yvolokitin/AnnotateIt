import 'package:flutter/material.dart';

class SelectCheckboxOverlay extends StatelessWidget {
  final bool isVisible;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectCheckboxOverlay({
    required this.isVisible,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
