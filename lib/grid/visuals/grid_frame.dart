import 'package:magic_blocks/theme/light_theme.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Board with a primary colored frame, drawn behind the cells and blocks.
class GridFrame extends PositionComponent {
  static const double frameWidth = 6;

  GridFrame({required super.size}) : super(priority: -10);

  @override
  void render(Canvas canvas) {
    final board = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(board, Paint()..color = colorScheme.surface);
    canvas.drawRect(
      board.inflate(frameWidth / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = frameWidth
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.primary, colorScheme.secondary],
        ).createShader(board.inflate(frameWidth)),
    );
  }
}
