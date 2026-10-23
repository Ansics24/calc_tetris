import 'package:calc_tetris/global/score/score_display.dart';
import 'package:calc_tetris/global/score/score_display_style.dart';
import 'package:calc_tetris/global/theme/light_theme.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  group('ScoreDisplayStyle.fromColorScheme', () {
    final style = ScoreDisplayStyle.fromColorScheme(colorScheme);
    final decoration = style.decoration;

    test('uses the container colors of the theme for the card', () {
      expect(decoration.color, colorScheme.primaryContainer);
      expect(style.textStyle.color, colorScheme.onPrimaryContainer);
      expect(style.labelStyle.color, colorScheme.onPrimaryContainer);
    });

    test('has a rounded, primary colored border', () {
      final border = decoration.border! as Border;
      expect(border.top.color, colorScheme.primary);
      expect(border.top.width, greaterThanOrEqualTo(3));
      expect(decoration.borderRadius, isNotNull);
    });

    test('is readable: big number, smaller label', () {
      expect(style.textStyle.fontSize, greaterThanOrEqualTo(32));
      expect(style.textStyle.fontWeight, FontWeight.bold);
      expect(style.labelStyle.fontSize, lessThan(style.textStyle.fontSize!));
      expect(style.labelStyle.fontSize, greaterThanOrEqualTo(14));
    });

    test('number text contrasts with the card background', () {
      final background = decoration.color!;
      final text = style.textStyle.color!;
      final contrast =
          (background.computeLuminance() + 0.05) /
          (text.computeLuminance() + 0.05);
      expect(contrast > 4.5 || contrast < 1 / 4.5, isTrue);
    });
  });

  group('ScoreDisplay label', () {
    test('is labelled in german', () {
      expect(ScoreDisplay.labelText, 'Punkte');
    });

    test('renders with label without error', () {
      final display = ScoreDisplay(
        size: Vector2(200, 80),
        style: ScoreDisplayStyle.fromColorScheme(colorScheme),
      )..score = 120;
      display.update(2.0);
      expect(display.displayedScore, 120);
    });
  });
}
