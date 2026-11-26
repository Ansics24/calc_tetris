import 'package:magic_blocks/theme/light_theme.dart';
import 'package:magic_blocks/theme/text_theme.dart';
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
      const Radius.circular(24),
    );
    canvas.drawRRect(
      panel.shift(const Offset(0, 4)),
      Paint()..color = colorScheme.shadow,
    );
    canvas.drawRRect(panel, Paint()..color = colorScheme.surface);
    canvas.drawRRect(
      panel.deflate(1.5),
      Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    TextPaint(
      style: textTheme.headlineLarge!.copyWith(color: colorScheme.tertiary),
    ).render(canvas, message, size / 2, anchor: Anchor.center);
  }
}
