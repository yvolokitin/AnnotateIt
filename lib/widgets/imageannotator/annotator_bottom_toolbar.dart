import 'package:flutter/material.dart';

class BottomToolbar extends StatelessWidget {
  final double scale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const BottomToolbar({
    super.key,
    required this.scale,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        // borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in_map, color: Colors.white),
            onPressed: () {},
          ),
          Text("Zoom: ${scale.toStringAsFixed(1)}x", style: const TextStyle(color: Colors.white)),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white),
                onPressed: onZoomOut,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white),
                onPressed: onZoomIn,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
