import 'package:flutter/material.dart';

class TaskConfirmationWidget extends StatelessWidget {
  const TaskConfirmationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 64),
        SizedBox(height: 16),
        Text(
          "Confirm the dataset information above.",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ],
    );
  }
}
