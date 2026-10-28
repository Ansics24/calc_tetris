import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flutter/painting.dart';
import 'package:test/test.dart';

/// WCAG contrast ratio between two colors.
double _contrast(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('uses a light sky as background', () {
    expect(WelcomePalette.skyTop.computeLuminance(), greaterThan(0.5));
    expect(WelcomePalette.skyBottom.computeLuminance(), greaterThan(0.5));
  });

  test('uses a light fill for the cards', () {
    expect(WelcomePalette.cardFill.computeLuminance(), greaterThan(0.8));
  });

  test('keeps all card texts well readable on the card', () {
    for (final textColor in [
      WelcomePalette.cardTitle,
      WelcomePalette.cardText,
      WelcomePalette.cardTextMuted,
      WelcomePalette.scoreValue,
    ]) {
      expect(_contrast(textColor, WelcomePalette.cardFill), greaterThan(4.5));
    }
  });
}
