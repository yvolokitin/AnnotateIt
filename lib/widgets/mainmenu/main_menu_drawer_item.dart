import 'package:flutter/material.dart';

class MainMenuDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const MainMenuDrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseRed = Colors.red;
    final Color lighterRed = baseRed.withAlpha(26); // 10% of 255
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: screenWidth>1600 ? 100 : 80,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: isSelected ? lighterRed : Colors.transparent,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: screenWidth>1600 ? 30 : 26,
                  color: isSelected ? Colors.red : Colors.white
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth>1600 ? 28 : 24,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
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
      ),
    );
  }
}
