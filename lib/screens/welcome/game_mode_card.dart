import 'dart:math';

import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:calc_tetris/util/german_number_format.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// Card presenting one game mode with its image, description and high score.
class GameModeCard extends PositionComponent with TapCallbacks {
  static const double cornerRadius = 24;
  static const double _borderWidth = 3;
  static const double _padding = 14;
  static const double _imageSize = 72;
  static const double _scoreColumnWidth = 110;
  static const double _minDescriptionWidth = 40;
  static const double _scoreGap = 2;
  static const double _descriptionTop = 44;

  final String title;
  final String description;
  final int highScore;
  final void Function()? onTap;

  GameModeCard({
    required this.title,
    required this.description,
    required this.highScore,
    required Vector2 size,
    this.onTap,
  }) : super(size: size) {
    _layout();
  }

  late final RectangleComponent imagePlaceholder = RectangleComponent(
    size: Vector2.all(_imageSize),
    paint: Paint()..color = WelcomePalette.imageFill,
  );

  late final TextComponent titleText = TextComponent(
    text: title,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: WelcomePalette.cardTitle,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  late final TextBoxComponent descriptionText = TextBoxComponent(
    text: description,
    textRenderer: TextPaint(
      style: const TextStyle(color: WelcomePalette.cardText, fontSize: 15),
    ),
    boxConfig: const TextBoxConfig(),
  );

  late final TextComponent highScoreLabel = TextComponent(
    text: 'Höchstpunktzahl',
    anchor: Anchor.topRight,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: WelcomePalette.cardTextMuted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  late final TextComponent highScoreValue = TextComponent(
    text: formatGermanNumber(highScore),
    anchor: Anchor.topCenter,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: WelcomePalette.scoreValue,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  /// Resizes the card and arranges its content for the new [newSize].
  void resizeTo(Vector2 newSize) {
    size = newSize;
    _layout();
  }

  /// Reports that the player chose this game mode.
  void press() => onTap?.call();

  void _layout() {
    final textX = _padding * 2 + _imageSize;
    final scoreRight = width - _padding;
    imagePlaceholder.position = Vector2(_padding, (height - _imageSize) / 2);
    titleText.position = Vector2(textX, _padding);
    descriptionText.position = Vector2(textX, _padding + _descriptionTop);
    descriptionText.boxConfig = TextBoxConfig(
      maxWidth: max(
        _minDescriptionWidth,
        width - textX - _scoreColumnWidth - _padding,
      ),
    );
    highScoreLabel.position = Vector2(scoreRight, _padding);
    highScoreValue.position = Vector2(
      scoreRight - highScoreLabel.width / 2,
      _padding + highScoreLabel.height + _scoreGap,
    );
  }

  @override
  Future<void> onLoad() async {
    await addAll([
      imagePlaceholder,
      titleText,
      descriptionText,
      highScoreLabel,
      highScoreValue,
    ]);
  }

  @override
  void render(Canvas canvas) {
    final shape = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(
      shape.shift(const Offset(0, 4)),
      Paint()..color = WelcomePalette.cardShadow,
    );
    canvas.drawRRect(shape, Paint()..color = WelcomePalette.cardFill);
    canvas.drawRRect(
      shape.deflate(_borderWidth / 2),
      Paint()
        ..color = WelcomePalette.cardBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth,
    );
    super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) => press();
}
