import 'package:calc_tetris/layout/header/score/count_up_animation.dart';
import 'package:calc_tetris/layout/header/score/score_display_style.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Shows a score and counts smoothly up whenever [score] is raised.
class ScoreDisplay extends PositionComponent {
  final ScoreDisplayStyle style;
  final CountUpAnimation _animation;
  late final BoxPainter _decorationPainter = style.decoration.createBoxPainter(
    () {},
  );
  late final TextPaint _textPaint = TextPaint(style: style.textStyle);
  late final TextPaint _labelPaint = TextPaint(style: style.labelStyle);

  static const String labelText = 'Punkte';

  ScoreDisplay({
    super.size,
    super.position,
    super.anchor,
    this.style = ScoreDisplayStyle.standard,
    double countUpDuration = 1.2,
  }) : _animation = CountUpAnimation(duration: countUpDuration);

  int get displayedScore => _animation.value;

  set score(int value) => _animation.animateTo(value);

  @override
  void update(double dt) {
    super.update(dt);
    _animation.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _decorationPainter.paint(
      canvas,
      Offset.zero,
      ImageConfiguration(size: Size(size.x, size.y)),
    );
    _textPaint.render(
      canvas,
      displayedScore.toString(),
      Vector2(size.x / 2, size.y * 0.62),
      anchor: Anchor.center,
    );
    _labelPaint.render(
      canvas,
      labelText,
      Vector2(size.x / 2, size.y * 0.2),
      anchor: Anchor.center,
    );
  }
}
