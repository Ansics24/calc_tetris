import 'package:flutter/material.dart';

/// Look of the [NextBlockDisplay]: card decoration plus the label text style.
class NextBlockDisplayStyle {
  final BoxDecoration decoration;
  final TextStyle labelStyle;

  const NextBlockDisplayStyle({
    required this.decoration,
    required this.labelStyle,
  });

  factory NextBlockDisplayStyle.fromColorScheme(ColorScheme scheme) =>
      NextBlockDisplayStyle(
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.fromBorderSide(
            BorderSide(color: scheme.secondary, width: 3),
          ),
        ),
        labelStyle: TextStyle(
          color: scheme.onSecondaryContainer,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
}
