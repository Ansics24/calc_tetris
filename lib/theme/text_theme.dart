import 'package:flutter/material.dart';

/// Rounded, playful font that suits a game for children (SIL Open Font
/// License, see `assets/fonts/OFL.txt`).
const String gameFontFamily = 'Fredoka';

/// Typography of the game: all texts take font family and size from here. The
/// styles carry no color, colors come from the color scheme.
final TextTheme textTheme = TextTheme(
  displayLarge: _style(36, FontWeight.bold),
  displaySmall: _style(30, FontWeight.bold),
  headlineLarge: _style(32, FontWeight.bold),
  headlineMedium: _style(26, FontWeight.bold),
  titleLarge: _style(22, FontWeight.bold),
  titleMedium: _style(20, FontWeight.bold),
  bodyLarge: _style(16, FontWeight.w600),
  bodyMedium: _style(15, FontWeight.w500),
  labelLarge: _style(15, FontWeight.w700),
  labelMedium: _style(13, FontWeight.w600),
);

TextStyle _style(double size, FontWeight weight) =>
    TextStyle(fontFamily: gameFontFamily, fontSize: size, fontWeight: weight);
