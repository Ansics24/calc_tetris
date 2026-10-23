import 'package:calc_tetris/global/theme/light_theme.dart';
import 'package:calc_tetris/layout/header/hud/hud_panel.dart';
import 'package:calc_tetris/layout/header/next_block_display_style.dart';
import 'package:calc_tetris/theme/game_palette.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  group('NextBlockDisplayStyle.fromColorScheme', () {
    final style = NextBlockDisplayStyle.fromColorScheme(colorScheme);

    test('shares the gold framed dark panel with the other HUD cards', () {
      expect(style.decoration, hudPanelDecoration);
    });

    test('has a rounded, copper colored border', () {
      final border = style.decoration.border! as Border;
      expect(border.top.color, GamePalette.copper);
      expect(style.decoration.borderRadius, isNotNull);
    });

    test('label is readable on the dark panel', () {
      expect(style.labelStyle.color, colorScheme.onSurface);
      expect(style.labelStyle.fontSize, greaterThanOrEqualTo(14));
    });
  });
}
