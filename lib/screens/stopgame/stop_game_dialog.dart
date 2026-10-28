import 'dart:async';

import 'package:calc_tetris/screens/stopgame/dialog_button.dart';
import 'package:calc_tetris/theme/game_palette.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// Modal question whether the running game should really be ended. Covers the
/// whole game and swallows taps and drags so nothing below is touched.
class StopGameDialog extends PositionComponent
    with TapCallbacks, DragCallbacks {
  static const String message = 'Spiel wirklich beenden?';
  static const double _panelHeight = 160;
  static const double _buttonGap = 20;

  final void Function() onConfirm;
  final void Function() onCancel;

  StopGameDialog({
    required Vector2 size,
    required this.onConfirm,
    required this.onCancel,
  }) : super(size: size, priority: 1000) {
    final buttonSize = Vector2(100, 44);
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    messageText = TextComponent(
      text: message,
      anchor: Anchor.center,
      position: Vector2(centerX, centerY - 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GamePalette.text,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    final buttonY = centerY + 5;
    yesButton = DialogButton(
      label: 'Ja',
      onPressed: onConfirm,
      size: buttonSize,
      position: Vector2(centerX - _buttonGap / 2 - buttonSize.x, buttonY),
    );
    noButton = DialogButton(
      label: 'Nein',
      onPressed: onCancel,
      size: buttonSize,
      position: Vector2(centerX + _buttonGap / 2, buttonY),
    );
  }

  late final TextComponent messageText;
  late final DialogButton yesButton;
  late final DialogButton noButton;

  @override
  FutureOr<void> onLoad() async {
    await addAll([messageText, yesButton, noButton]);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0x99000000),
    );
    final panel = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x * 0.8,
        height: _panelHeight,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(panel, Paint()..color = GamePalette.panel);
    canvas.drawRRect(
      panel,
      Paint()
        ..color = GamePalette.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
