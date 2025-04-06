import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:vap/data/providers.dart';
import 'package:vap/data/app_database.dart';

class LearnWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Learn",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Update DB"),
          ),
        ],
      ),
    );
  }
}
