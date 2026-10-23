import 'package:calc_tetris/theme/game_palette.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// Round button in the header that triggers [onPressed] when tapped. Paints a
/// double arrow pointing down.
class DropButton extends PositionComponent with TapCallbacks {
  final void Function() onPressed;
  bool _pressed = false;

  DropButton({required this.onPressed, super.size, super.position});

  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _pressed = false;
    onPressed();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressed = false;
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = _pressed ? GamePalette.goldDark : GamePalette.panel,
    );
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = GamePalette.copper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _renderDoubleArrow(canvas, center, radius * 0.45);
  }

  void _renderDoubleArrow(Canvas canvas, Offset center, double halfWidth) {
    final paint = Paint()
      ..color = GamePalette.gold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    for (final offsetY in [-halfWidth * 0.5, halfWidth * 0.5]) {
      final tip = center.translate(0, offsetY + halfWidth * 0.4);
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx - halfWidth, tip.dy - halfWidth * 0.8)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + halfWidth, tip.dy - halfWidth * 0.8),
        paint,
      );
    }
  }
}
