import 'package:flutter/material.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  AppHeaderState createState() => AppHeaderState();
}

class AppHeaderState extends State<AppHeader> {
  double _getHeaderHeight(double width) {
    if (width >= 1600) return 88; // large screens
    if (width >= 1200) return 72; // medium screens
    return 56; // small screens
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = _getHeaderHeight(screenWidth);

    return Container(
      height: headerHeight,
      color: Colors.red,
      // padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (screenWidth>1600)
            const SizedBox(width: 20),

          Container(
            width: 71,
            height: headerHeight,
            padding: EdgeInsets.all(screenWidth>1600 ? 2 : 10),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            // clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/logo/annotateit_white.png', // annotateit.png',
              height: headerHeight,
            ),
          ),

          const Spacer(),
          Container(
            height: headerHeight,
            padding: EdgeInsets.only(
              top: screenWidth>1600 ? 16 : (screenWidth>1200 ? 12 : 8),
              bottom: 10,
            ),
            child: Text(
              'annot@It',
              style: TextStyle(
                fontSize: screenWidth>1600 ? 30 : (screenWidth>1200 ? 24 : 20),
                fontWeight: FontWeight.bold,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ),
          SizedBox(width: screenWidth>1600 ? 16 : 12),
        ],
      ),
    );
  }
}
