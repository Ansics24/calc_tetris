import 'package:calc_tetris/theme/light_theme.dart';
import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  test('is a bright theme', () {
    expect(colorScheme.brightness, Brightness.light);
  });

  test(
    'cards are white framed in sunny orange, like on the welcome screen',
    () {
      expect(colorScheme.primaryContainer, WelcomePalette.cardFill);
      expect(colorScheme.primary, WelcomePalette.cardBorder);
    },
  );

  test('texts have the colors of the welcome cards', () {
    expect(colorScheme.onPrimaryContainer, WelcomePalette.cardText);
    expect(colorScheme.onSurface, WelcomePalette.cardText);
    expect(colorScheme.tertiary, WelcomePalette.cardTitle);
  });

  test('surfaces such as the board and dialogs are white', () {
    expect(colorScheme.surface, WelcomePalette.cardFill);
    expect(colorScheme.surfaceContainerHigh, WelcomePalette.cardFill);
  });
}
