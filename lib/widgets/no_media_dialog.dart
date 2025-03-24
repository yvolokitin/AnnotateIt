import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';

class NoMediaDialog extends StatefulWidget {
  final int project_id;
  final String dataset_id;

  NoMediaDialog({
    required this.project_id,
    required this.dataset_id,
    super.key,
  });

  @override
  _NoMediaDialogState createState() => _NoMediaDialogState();
}

class _NoMediaDialogState extends State<NoMediaDialog> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.grey[900], // background
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow, width: 3), // 👈 Yellow border
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[900],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Row(
              children: [
                Text("Import dataset", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),              ],
            ),
          ),

          SizedBox(width: 20),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[900],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Row(
              children: [
                Text("Upload media", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),              ],
            ),
          ),
        ],
      ),
    );
  }
}
