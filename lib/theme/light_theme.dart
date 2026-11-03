import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flutter/material.dart';

/// Bright, friendly scheme of the whole game: white cards framed in sunny
/// orange, dark blue-gray text. Matches the look of the welcome screen.
final colorScheme =
    ColorScheme.fromSeed(
      seedColor: WelcomePalette.cardBorder,
      brightness: Brightness.light,
    ).copyWith(
      primary: WelcomePalette.cardBorder,
      primaryContainer: WelcomePalette.cardFill,
      onPrimaryContainer: WelcomePalette.cardText,
      tertiary: WelcomePalette.cardTitle,
      surface: WelcomePalette.cardFill,
      surfaceContainerHigh: WelcomePalette.cardFill,
      onSurface: WelcomePalette.cardText,
      shadow: WelcomePalette.cardShadow,
    );
