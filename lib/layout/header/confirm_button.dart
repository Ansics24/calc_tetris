import 'package:calc_tetris/theme/light_theme.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// Round button in the header that triggers [onPressed] when tapped. Paints a
/// checkmark.
class ConfirmButton extends PositionComponent with TapCallbacks {
  final void Function() onPressed;
  bool _pressed = false;

  ConfirmButton({required this.onPressed, super.size, super.position});

  /// Reports that the player wants to confirm the block's position.
  void press() => onPressed();

  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _pressed = false;
    press();
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
      Paint()
        ..color = _pressed ? colorScheme.primary : colorScheme.primaryContainer,
    );
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _renderCheckmark(canvas, center, radius * 0.45);
  }

  void _renderCheckmark(Canvas canvas, Offset center, double half) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - half, center.dy + half * 0.1)
        ..lineTo(center.dx - half * 0.3, center.dy + half * 0.8)
        ..lineTo(center.dx + half, center.dy - half * 0.7),
      Paint()
        ..color = colorScheme.tertiary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 4,
    );
  }
}
