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
    this.labelStyle = const TextStyle(
      color: Color(0xFFFFF3C4),
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
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

  static const TextStyle standardTextStyle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle standardLabelStyle = TextStyle(
    color: Color(0xFFB8C4DC),
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const ScoreDisplayStyle standard = ScoreDisplayStyle(
    decoration: BoxDecoration(
      color: Color.fromARGB(200, 20, 16, 16),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      border: Border.fromBorderSide(
        BorderSide(color: Color(0xFFD4AF37), width: 3),
      ),
    ),
    textStyle: TextStyle(
      color: Color(0xFFFFF3C4),
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  );
}
