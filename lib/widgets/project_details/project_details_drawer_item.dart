import 'package:flutter/material.dart';

class ProjectDetailsDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool fullMode;
  final bool isSelected;
  final double textSize;
  final VoidCallback onTap;

  const ProjectDetailsDrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.fullMode = false,
    this.textSize = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseRed = Colors.red;
    final Color lighterRed = baseRed.withAlpha(26); // 10% of 255
    
    return Stack(
      children: [
        Container(
          height: 100,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected ? lighterRed : Colors.transparent,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 40, right: 16),
            title: SizedBox(
              height: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.red : null,
                  ),
                  if (fullMode) SizedBox(width: 16),
                  if (fullMode)
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: textSize,
                        color: isSelected ? Colors.white : Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
            selected: isSelected,
            onTap: onTap,
          ),
        ),
        if (isSelected)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}