import 'package:flame/game.dart';

class GameDimensions {
  static final double _borderLeftRightPercentage = 0.1;
  static final double _borderTopPercentage = 0.3;
  static final double _borderBottomPercentage = 0.1;

  int _borderLeftRight = 0;
  int _borderTop = 0;
  int _borderBottom = 0;
  Vector2 _availableSize = Vector2.zero();

  set availableSize(Vector2 size) {
    _availableSize = size;
    _borderLeftRight = (_availableSize.x * _borderLeftRightPercentage).toInt();
    _borderTop = (_availableSize.y * _borderTopPercentage).toInt();
    _borderBottom = (_availableSize.y * _borderBottomPercentage).toInt();
  }

  Vector2 gameAreaStart() {
    return Vector2(_borderLeftRight.toDouble(), borderTop.toDouble());
  }

  Vector2 gameAreaSize() {
    return Vector2(
      _availableSize.x - 2 * _borderLeftRight,
      _availableSize.y - _borderTop - _borderBottom,
    );
  }

  int get borderLeftRight => _borderLeftRight;

  int get borderTop => _borderTop;

  int get borderBottom => _borderBottom;
}
