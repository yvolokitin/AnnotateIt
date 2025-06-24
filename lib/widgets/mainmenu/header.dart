import 'package:flutter/material.dart';

class AppHeader extends StatefulWidget {
  final VoidCallback? onHeaderPressed;

  const AppHeader({super.key, this.onHeaderPressed});

  @override
  AppHeaderState createState() => AppHeaderState();
}

class AppHeaderState extends State<AppHeader> {
  double _getHeaderHeight(double width) {
    if (width >= 1600) return 88;     // large screens
    if (width >= 1200) return 72;     // medium screens
    return 56;                        // small screens
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = _getHeaderHeight(screenWidth);

    return Container(
      height: headerHeight,
      color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.onHeaderPressed != null)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: widget.onHeaderPressed,
            ),
          const SizedBox(width: 10),
          const Icon(Icons.widgets, color: Colors.white),
          const SizedBox(width: 10),
          const Text(
            "Annot@It",
            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
