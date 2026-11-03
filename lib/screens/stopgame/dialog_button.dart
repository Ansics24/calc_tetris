import 'package:calc_tetris/theme/light_theme.dart';
import 'package:calc_tetris/theme/text_theme.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// Rectangular text button of a dialog.
class DialogButton extends PositionComponent with TapCallbacks {
  final String label;
  final void Function() onPressed;
  bool _pressed = false;

  DialogButton({
    required this.label,
    required this.onPressed,
    super.size,
    super.position,
  });

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
    final shape = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..color = _pressed ? colorScheme.primary : colorScheme.primaryContainer,
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    TextPaint(
      style: textTheme.titleMedium!.copyWith(
        color: colorScheme.onPrimaryContainer,
      ),
    ).render(canvas, label, size / 2, anchor: Anchor.center);
  }
}
