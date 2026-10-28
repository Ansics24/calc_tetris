import 'package:flame/components.dart';

/// Where the parts of the header sit inside its size: the score card on the
/// left, the next-block card on the right and the drop button in between.
class HeaderLayout {
  final Vector2 size;

  const HeaderLayout(this.size);

  static const double _margin = 0.03;
  static const double _cardWidth = 0.4;

  Vector2 get cardSize => Vector2(size.x * _cardWidth, size.y * 0.7);

  double get _cardTop => size.y * 0.15;

  Vector2 get scoreCardPosition => Vector2(size.x * _margin, _cardTop);

  Vector2 get nextBlockCardPosition =>
      Vector2(size.x * (1 - _margin - _cardWidth), _cardTop);

  Vector2 get dropButtonSize =>
      Vector2.all(size.x * (1 - 2 * (_margin + _cardWidth)) * 0.75);

  Vector2 get dropButtonPosition => Vector2(
    (size.x - dropButtonSize.x) / 2,
    (size.y - dropButtonSize.y) / 2,
  );

  Vector2 get stopButtonSize => dropButtonSize;

  /// Top of the header, far enough above the drop button to not hit it by
  /// accident.
  Vector2 get stopButtonPosition =>
      Vector2(dropButtonPosition.x, size.y * 0.05);
}
