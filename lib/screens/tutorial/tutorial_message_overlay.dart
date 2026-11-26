import 'dart:math';
import 'dart:ui';

import 'package:magic_blocks/screens/stopgame/dialog_button.dart';
import 'package:magic_blocks/theme/light_theme.dart';
import 'package:magic_blocks/theme/text_theme.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// A pause of the tutorial: a panel at the bottom with an explaining text and
/// a button to go on. Covers the whole game and swallows taps and drags, so
/// the board below stays untouched while the player reads.
class TutorialMessageOverlay extends PositionComponent
    with TapCallbacks, DragCallbacks {
  static const double _margin = 16;
  static const double _padding = 20;
  static const double _panelHeight = 230;
  static const double _bottomGap = 24;
  static const Size _buttonSize = Size(180, 48);

  final void Function() onContinue;

  late final TextBoxComponent messageText;
  late final DialogButton continueButton;

  TutorialMessageOverlay({
    required String text,
    required String buttonLabel,
    required Vector2 size,
    required this.onContinue,
  }) : super(size: size, priority: 1000) {
    final panel = panelRect;
    messageText = TextBoxComponent(
      text: text,
      position: Vector2(panel.left + _padding, panel.top + _padding),
      textRenderer: TextPaint(
        style: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      ),
      boxConfig: TextBoxConfig(
        maxWidth: max(40, panel.width - 2 * _padding),
      ),
    );
    continueButton = DialogButton(
      label: buttonLabel,
      onPressed: onContinue,
      size: Vector2(_buttonSize.width, _buttonSize.height),
      position: Vector2(
        panel.center.dx - _buttonSize.width / 2,
        panel.bottom - _padding - _buttonSize.height,
      ),
    );
    addAll([messageText, continueButton]);
  }

  /// The visible panel at the bottom. The area above stays free.
  Rect get panelRect => Rect.fromLTWH(
    _margin,
    size.y - _bottomGap - _panelHeight,
    size.x - 2 * _margin,
    _panelHeight,
  );

  @override
  void render(Canvas canvas) {
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(24));
    canvas.drawRRect(
      panel.shift(const Offset(0, 4)),
      Paint()..color = colorScheme.shadow,
    );
    canvas.drawRRect(panel, Paint()..color = colorScheme.surface);
    canvas.drawRRect(
      panel.deflate(1.5),
      Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    super.render(canvas);
  }
}
