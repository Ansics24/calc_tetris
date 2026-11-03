import 'package:calc_tetris/layout/header/hud/hud_panel.dart';
import 'package:calc_tetris/theme/text_theme.dart';
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
        labelStyle: textTheme.labelLarge!.copyWith(
          color: scheme.onPrimaryContainer,
        ),
      );
}
