import 'package:magic_blocks/layout/header/hud/hud_panel.dart';
import 'package:magic_blocks/layout/header/next_block_display_style.dart';
import 'package:magic_blocks/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  group('NextBlockDisplayStyle.fromColorScheme', () {
    final style = NextBlockDisplayStyle.fromColorScheme(colorScheme);

    test('shares the themed panel with the other HUD cards', () {
      expect(style.decoration, hudPanelDecoration);
    });

    test('panel uses the container colors of the theme', () {
      expect(style.decoration.color, colorScheme.primaryContainer);
    });

    test('has a rounded, primary colored border', () {
      final border = style.decoration.border! as Border;
      expect(border.top.color, colorScheme.primary);
      expect(style.decoration.borderRadius, isNotNull);
    });

    test('label is readable on the panel', () {
      expect(style.labelStyle.color, colorScheme.onPrimaryContainer);
      expect(style.labelStyle.fontSize, greaterThanOrEqualTo(14));
    });
  });
}
