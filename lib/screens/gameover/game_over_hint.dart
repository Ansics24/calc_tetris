import 'package:calc_tetris/theme/light_theme.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Temporary hint that the game is over. To be replaced by a game over
/// screen: delete this file and its use in `EndlessGame`.
class GameOverHint extends PositionComponent {
  static const String message = 'Spiel vorbei!';

  GameOverHint({required super.size}) : super(priority: 1000);

  @override
  void render(Canvas canvas) {
    final panel = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x * 0.8,
        height: 90,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(panel, Paint()..color = colorScheme.scrim.withAlpha(200));
    TextPaint(
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ).render(canvas, message, size / 2, anchor: Anchor.center);
  }
}
