import 'package:calc_tetris/theme/game_palette.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// Round button in the header that triggers [onPressed] when tapped. Paints a
/// stop square.
class StopButton extends PositionComponent with TapCallbacks {
  final void Function() onPressed;
  bool _pressed = false;

  StopButton({required this.onPressed, super.size, super.position});

  /// Reports that the player wants to stop the game.
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
    final half = radius * 0.4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: half * 2, height: half * 2),
        const Radius.circular(3),
      ),
      Paint()..color = GamePalette.gold,
    );
  }
}
