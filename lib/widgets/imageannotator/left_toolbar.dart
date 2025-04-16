import 'package:flutter/material.dart';

class LeftToolbar extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onOpacityChanged;

  const LeftToolbar({
    super.key,
    required this.opacity,
    required this.onOpacityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      color: Colors.grey[900],
      child: Column(
        children: [
          const Divider(color: Colors.white30, height: 20),
          IconButton(
            icon: const Icon(Icons.crop_square, color: Colors.white),
            onPressed: () {}, // TODO: Tool selection
          ),

          const Divider(color: Colors.white30, height: 20),
          IconButton(
            icon: const Icon(Icons.polyline, color: Colors.white),
            onPressed: () {},
          ),

          const Divider(color: Colors.white30, height: 20),
          IconButton(
            icon: const Icon(Icons.select_all, color: Colors.white),
            onPressed: () {},
          ),

          const Divider(color: Colors.white30, height: 20),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {},
          ),

          const Divider(color: Colors.white30, height: 20),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showOpacityDialog(context),
          ),
        ],
      ),
    );
  }

  void _showOpacityDialog(BuildContext context) {
    double tempOpacity = opacity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Annotation Fill Opacity'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: tempOpacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(tempOpacity * 100).round()}%',
                    onChanged: (value) => setState(() => tempOpacity = value),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onOpacityChanged(tempOpacity);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
