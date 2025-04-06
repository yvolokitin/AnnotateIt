import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final double? maxSize;
  final double? minSize;
  final double? breakpoint;
  final double? height;
  final Color? color;
  final TextStyle? style; // custom style override
  final String? themeStyle; // e.g. 'bodySmall', 'titleMedium', etc.

  const ResponsiveText(
    this.text, {
    super.key,
    this.textAlign,
    this.fontWeight,
    this.maxSize = 20,
    this.minSize = 14,
    this.breakpoint = 1600,
    this.height,
    this.color,
    this.style,
    this.themeStyle = 'bodySmall',
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width >= breakpoint! ? maxSize! : minSize!;

    // Grab base text style from theme
    TextStyle baseStyle = switch (themeStyle) {
      'bodyLarge' => Theme.of(context).textTheme.bodyLarge!,
      'bodyMedium' => Theme.of(context).textTheme.bodyMedium!,
      'bodySmall' => Theme.of(context).textTheme.bodySmall!,
      'titleLarge' => Theme.of(context).textTheme.titleLarge!,
      'titleMedium' => Theme.of(context).textTheme.titleMedium!,
      'titleSmall' => Theme.of(context).textTheme.titleSmall!,
      'labelSmall' => Theme.of(context).textTheme.labelSmall!,
      _ => Theme.of(context).textTheme.bodySmall!,
    };

    // Override properties if provided
    final effectiveStyle = baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight ?? baseStyle.fontWeight,
      color: color ?? baseStyle.color,
      height: height ?? baseStyle.height,
    );

    return Text(
      text,
      textAlign: textAlign,
      style: style ?? effectiveStyle,
    );
  }
}
