import 'package:calc_tetris/global/theme/game_palette.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Dark board with a copper frame, drawn behind the cells and blocks.
class GridFrame extends PositionComponent {
  static const double frameWidth = 6;

  GridFrame({required super.size}) : super(priority: -10);

  @override
  void render(Canvas canvas) {
    final board = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(board, Paint()..color = GamePalette.boardFill);
    canvas.drawRect(
      board.inflate(frameWidth / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = frameWidth
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GamePalette.copper, GamePalette.goldDark],
        ).createShader(board.inflate(frameWidth)),
    );
  }
}
