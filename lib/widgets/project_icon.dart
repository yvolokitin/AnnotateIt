import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class ProjectIcon extends StatelessWidget {
  final String iconPath;

  const ProjectIcon({
    Key? key,
    required this.iconPath,
  }) : super(key: key);

  bool get isSvg => iconPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (iconPath.isEmpty) return _placeholder();

    try {
      if (isSvg) {
        return SizedBox(
          width: 45,
          height: 45,
          child: SvgPicture.file(
            File(iconPath),
            fit: BoxFit.contain,
            placeholderBuilder: (context) => _placeholder(),
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
      width: isSvg ? 45 : double.infinity,
      height: isSvg ? 45 : double.infinity,
      color: Colors.grey[700],
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54),
      ),
    );
  }
}
