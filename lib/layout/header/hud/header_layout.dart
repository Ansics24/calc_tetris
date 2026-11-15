import 'dart:math';

import 'package:flame/components.dart';

/// Where the parts of the header sit inside its size: the score card on the
/// left, the next-block card on the right and the confirm button in between.
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

  /// Gap between the stop and the confirm button, in button heights. Keeps the
  /// stop button far enough above the confirm button to not hit it by accident.
  static const double _buttonGap = 0.5;

  Vector2 get confirmButtonSize {
    final fromWidth = size.x * (1 - 2 * (_margin + _cardWidth)) * 0.75;
    final fromHeight = cardSize.y / (2 + _buttonGap);
    return Vector2.all(min(fromWidth, fromHeight));
  }

  Vector2 get stopButtonSize => confirmButtonSize;

  /// Both buttons are stacked and centered vertically between the top and the
  /// bottom of the cards.
  Vector2 get stopButtonPosition {
    final stackHeight = confirmButtonSize.y * (2 + _buttonGap);
    return Vector2(
      (size.x - stopButtonSize.x) / 2,
      _cardTop + (cardSize.y - stackHeight) / 2,
    );
  }

  Vector2 get confirmButtonPosition => Vector2(
    stopButtonPosition.x,
    stopButtonPosition.y + stopButtonSize.y * (1 + _buttonGap),
  );
}
