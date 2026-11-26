import 'dart:math';
import 'dart:ui';

import 'package:magic_blocks/theme/light_theme.dart';
import 'package:magic_blocks/theme/text_theme.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Round button of a power-up with a badge showing how many of them the
/// player has left. The picture of the power-up is up to the subclass.
abstract class PowerUpButton extends PositionComponent with TapCallbacks {
  /// Higher counts are shown as `99+`.
  static const int maxShownCount = 99;

  /// Size of the circle and of the badge, relative to the button size. The
  /// badge sits on the upper left rim of the circle and still fits into the button.
  static const double _circleRadiusFactor = 0.42;
  static const double _badgeRadiusFactor = 0.2;

  int _count;

  /// Called when the player selects this power-up.
  void Function()? onPressed;

  /// A locked button can not be pressed.
  bool isLocked = false;

  /// While the power-up is in use: how often it can still be used, otherwise
  /// null. The button then shows this number and is very transparent.
  int? activeUses;

  /// How opaque the button is while its power-up is in use.
  static const double _activeOpacity = 0.3;

  /// False for a power-up that only flies around and has no count to show.
  final bool showBadge;

  PowerUpButton({
    int count = 0,
    this.showBadge = true,
    super.size,
    super.position,
  }) : _count = _checked(count);

  /// Reports that the player wants to use the power-up. Does nothing while the
  /// button is locked or there is none left. The count is up to the game.
  void press() {
    if (isLocked || _count == 0) {
      return;
    }
    onPressed?.call();
  }

  @override
  void onTapUp(TapUpEvent event) => press();

  /// How many of these power-ups are left in the current round.
  int get count => _count;

  set count(int value) => _count = _checked(value);

  String? get usesText => activeUses?.toString();

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
    final uses = usesText;
    if (uses == null) {
      _renderButton(canvas);
      return;
    }
    // fades the whole button, the number stays fully visible on top
    canvas.saveLayer(
      null,
      Paint()..color = colorScheme.shadow.withValues(alpha: _activeOpacity),
    );
    _renderButton(canvas);
    canvas.restore();
    _renderUses(canvas, uses);
  }

  void _renderUses(Canvas canvas, String uses) {
    TextPaint(
      style: textTheme.displaySmall!.copyWith(
        fontSize: circleRect.height * 0.65,
        color: colorScheme.onSurface,
      ),
    ).render(
      canvas,
      uses,
      Vector2(circleRect.center.dx, circleRect.center.dy),
      anchor: Anchor.center,
    );
  }

  void _renderButton(Canvas canvas) {
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
    if (showBadge) {
      _renderBadge(canvas);
    }
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
