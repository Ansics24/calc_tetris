import 'dart:math';
import 'dart:ui';

import 'package:calc_tetris/theme/light_theme.dart';
import 'package:calc_tetris/theme/text_theme.dart';
import 'package:flame/components.dart';

/// Round button of a power-up with a badge showing how many of them the
/// player has left. The picture of the power-up is up to the subclass.
abstract class PowerUpButton extends PositionComponent {
  /// Higher counts are shown as `99+`.
  static const int maxShownCount = 99;

  /// Size of the circle and of the badge, relative to the button size. The
  /// badge sits on the upper left rim of the circle and still fits into the button.
  static const double _circleRadiusFactor = 0.42;
  static const double _badgeRadiusFactor = 0.2;

  int _count;

  PowerUpButton({int count = 0, super.size, super.position})
    : _count = _checked(count);

  /// How many of these power-ups are left in the current round.
  int get count => _count;

  set count(int value) => _count = _checked(value);

  String get badgeText =>
      _count > maxShownCount ? '$maxShownCount+' : '$_count';

  /// The circle of the button.
  Rect get circleRect {
    final shortSide = min(size.x, size.y);
    return Rect.fromCircle(
      center: Offset(size.x / 2, size.y / 2),
      radius: shortSide * _circleRadiusFactor,
    );
  }

  /// The badge on the upper left of the circle, so it never covers what the
  /// icon points to.
  Rect get badgeRect {
    final circle = circleRect;
    final rimOffset = circle.width / 2 * sqrt1_2;
    return Rect.fromCircle(
      center: Offset(
        circle.center.dx - rimOffset,
        circle.center.dy - rimOffset,
      ),
      radius: min(size.x, size.y) * _badgeRadiusFactor,
    );
  }

  /// Paints the picture of the power-up inside [area], a square in the middle
  /// of the circle.
  void paintIcon(Canvas canvas, Rect area);

  @override
  void render(Canvas canvas) {
    final circle = circleRect;
    canvas.drawCircle(
      circle.center,
      circle.width / 2,
      Paint()..color = colorScheme.primaryContainer,
    );
    canvas.drawCircle(
      circle.center,
      circle.width / 2 - 1,
      Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    paintIcon(
      canvas,
      Rect.fromCenter(
        center: circle.center,
        width: circle.width * 0.8,
        height: circle.width * 0.8,
      ),
    );
    _renderBadge(canvas);
  }

  void _renderBadge(Canvas canvas) {
    final badge = badgeRect;
    canvas.drawCircle(
      badge.center,
      badge.width / 2,
      Paint()..color = colorScheme.error,
    );
    final fontSize = badge.width * (badgeText.length > 2 ? 0.42 : 0.55);
    TextPaint(
      style: textTheme.labelMedium!.copyWith(
        fontSize: fontSize,
        color: colorScheme.onError,
      ),
    ).render(
      canvas,
      badgeText,
      Vector2(badge.center.dx, badge.center.dy),
      anchor: Anchor.center,
    );
  }

  static int _checked(int count) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'must not be negative');
    }
    return count;
  }
}
