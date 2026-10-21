import 'package:flutter/material.dart';

/// Look of the [ScoreDisplay]: any [BoxDecoration] (border, gradient, radius,
/// shadow, background image ...) plus the text style of the number.
class ScoreDisplayStyle {
  final BoxDecoration decoration;
  final TextStyle textStyle;

  const ScoreDisplayStyle({required this.decoration, required this.textStyle});

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
