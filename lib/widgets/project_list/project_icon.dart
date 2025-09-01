import 'package:flutter/material.dart';
import 'dart:io';

class ProjectIcon extends StatelessWidget {
  final String iconPath;

  const ProjectIcon({
    super.key,
    required this.iconPath,
  });

  bool get isDefault => iconPath.contains('empty_project_folder.png');

  @override
  Widget build(BuildContext context) {
    if (iconPath.isEmpty) return _placeholder();

    try {
      if (isDefault) {
      	return SizedBox(
	        width: 35,
	        height: 35,
	        child: Image.file(
	          File(iconPath),
	          fit: BoxFit.contain,
	          errorBuilder: (context, error, stackTrace) => _placeholder(),
	        ),
	      );
      } else {
        return Image.file(
          File(iconPath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      }
    } catch (e) {
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return Container(
      width: isDefault ? 35 : double.infinity,
      height: isDefault ? 35 : double.infinity,
      color: Colors.grey[700],
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54),
      ),
    );
  }
}
