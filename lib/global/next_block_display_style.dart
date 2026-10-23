import 'package:calc_tetris/global/hud/hud_panel.dart';
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
        decoration: hudPanelDecoration,
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      );
}
