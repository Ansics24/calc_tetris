import 'package:calc_tetris/global/next_block_display_style.dart';
import 'package:calc_tetris/global/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  group('NextBlockDisplayStyle.fromColorScheme', () {
    final style = NextBlockDisplayStyle.fromColorScheme(colorScheme);

    test('uses the secondary container colors of the theme', () {
      expect(style.decoration.color, colorScheme.secondaryContainer);
      expect(style.labelStyle.color, colorScheme.onSecondaryContainer);
    });

    test('has a rounded, secondary colored border', () {
      final border = style.decoration.border! as Border;
      expect(border.top.color, colorScheme.secondary);
      expect(style.decoration.borderRadius, isNotNull);
    });

    test('label is at least 14 px', () {
      expect(style.labelStyle.fontSize, greaterThanOrEqualTo(14));
    });
  });
}
