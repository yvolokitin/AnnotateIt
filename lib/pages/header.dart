import "package:flutter/material.dart";

class AppHeader extends StatefulWidget {
  final VoidCallback? onHeaderPressed;

  const AppHeader({super.key, this.onHeaderPressed});

  @override
  AppHeaderState createState() => AppHeaderState();
}

class AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // min size for the column
      children: [
        if (widget.onHeaderPressed == null)
          Container(
            width: double.infinity,
            height: 15,
            color: Colors.red,
          ),
        Container(
          color: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          child: Row(
            children: [
              // show menu button only on small screens
              if (widget.onHeaderPressed != null)
                IconButton(icon: Icon(Icons.menu, color: Colors.white), onPressed: widget.onHeaderPressed),
              
              SizedBox(width: 10),
              Icon(Icons.widgets, color: Colors.white),
              SizedBox(width: 10),
              Text("Annot@It", style: TextStyle(color: Colors.white, fontSize: 30)),
            ],
          ),
        ),
        // show horizontal line 30px for big screens only
        if (widget.onHeaderPressed == null)
          Container(
            width: double.infinity,
            height: 15,
            color: Colors.red,
          ),
      ],
    );
  }
}