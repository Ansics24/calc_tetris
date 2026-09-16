import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GridLine extends Component {
  final Vector2 start;
  final Vector2 end;

  GridLine(this.start, this.end);

  final Paint paint = Paint()
    ..color = const Color.fromARGB(9, 63, 9, 135)
    ..strokeWidth = 2;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      start.toOffset(),
      end.toOffset(),
      paint,
    );
  }
}
