import 'package:magic_blocks/theme/text_theme.dart';
import 'package:flutter/material.dart';

/// Look of the [ScoreDisplay]: any [BoxDecoration] (border, gradient, radius,
/// shadow, background image ...) plus the text styles of the number and label.
class ScoreDisplayStyle {
  final BoxDecoration decoration;
  final TextStyle textStyle;
  final TextStyle labelStyle;

  const ScoreDisplayStyle({
    required this.decoration,
    required this.textStyle,
    required this.labelStyle,
  });

  factory ScoreDisplayStyle.fromColorScheme(ColorScheme scheme) =>
      ScoreDisplayStyle(
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.fromBorderSide(
            BorderSide(color: scheme.primary, width: 3),
          ),
        ),
        textStyle: textTheme.displayLarge!.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        labelStyle: textTheme.bodyLarge!.copyWith(
          color: scheme.onPrimaryContainer,
        ),
      );

  ScoreDisplayStyle copyWith({BoxDecoration? decoration}) => ScoreDisplayStyle(
    decoration: decoration ?? this.decoration,
    textStyle: textStyle,
    labelStyle: labelStyle,
  );
}
