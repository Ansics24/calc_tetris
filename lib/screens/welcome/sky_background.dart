import 'dart:ui' as ui;

import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Light sky that fades from [topColor] down to [bottomColor].
class SkyBackground extends PositionComponent {
  final Color topColor = WelcomePalette.skyTop;
  final Color bottomColor = WelcomePalette.skyBottom;

  SkyBackground({super.size, super.position}) : super(priority: -1);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          topColor,
          bottomColor,
        ]),
    );
  }
}
