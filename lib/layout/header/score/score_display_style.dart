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
        textStyle: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  ScoreDisplayStyle copyWith({BoxDecoration? decoration}) => ScoreDisplayStyle(
    decoration: decoration ?? this.decoration,
    textStyle: textStyle,
    labelStyle: labelStyle,
  );
}
