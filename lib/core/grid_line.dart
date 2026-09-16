import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GridLine extends Component {
  final Vector2 start;
  final Vector2 end;

  GridLine(this.start, this.end);

  final Paint paint = Paint()
    ..color = const Color.fromARGB(206, 66, 28, 115)
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
