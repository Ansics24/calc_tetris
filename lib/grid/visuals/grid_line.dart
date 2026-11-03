import 'package:calc_tetris/theme/light_theme.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GridLine extends Component {
  final Vector2 start;
  final Vector2 end;

  GridLine(this.start, this.end);

  final Paint paint = Paint()
    ..color = colorScheme.outlineVariant
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawLine(
      start.toOffset(),
      end.toOffset(),
      paint,
    );
  }
}
