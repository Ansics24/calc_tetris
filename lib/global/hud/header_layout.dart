import 'package:flame/components.dart';

/// Where the parts of the header sit inside its size: the score card on the
/// left, the next-block card on the right.
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
}
