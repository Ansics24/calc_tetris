import 'package:calc_tetris/theme/light_theme.dart';
import 'package:calc_tetris/theme/text_theme.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// Small rounded button inside a game mode card. Handles its taps itself, so
/// the card below does not react to them.
class CardButton extends PositionComponent with TapCallbacks {
  final String label;
  final void Function()? onPressed;
  bool _pressed = false;

  CardButton({
    required this.label,
    this.onPressed,
    super.size,
    super.position,
  });

  void press() => onPressed?.call();

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
      Radius.circular(size.y / 2),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..color = _pressed ? colorScheme.primary : colorScheme.primaryContainer,
    );
    canvas.drawRRect(
      shape.deflate(1),
      Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    TextPaint(
      style: textTheme.labelLarge!.copyWith(
        color: colorScheme.onPrimaryContainer,
      ),
    ).render(canvas, label, size / 2, anchor: Anchor.center);
  }
}
