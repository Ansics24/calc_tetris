import 'package:flame/game.dart';

class GameDimensions {
  static final double _borderLeftRightPercentage = 0.1;
  static final double _borderTopPercentage = 0.3;
  static final double _borderBottomPercentage = 0.1;

  static final double percentageHeader = 0.25;
  static final double percentageFooter = 0.1;

  int _borderLeftRight = 0;
  int _borderTop = 0;
  int _borderBottom = 0;
  Vector2 _availableSize = Vector2.zero();

  Vector2 _sizeHeader = Vector2.zero();
  Vector2 _sizeFooter = Vector2.zero();
  Vector2 _sizeBlockBoard = Vector2.zero();

  set availableSize(Vector2 size) {
    _availableSize = size;
    _borderLeftRight = (_availableSize.x * _borderLeftRightPercentage).toInt();
    _borderTop = (_availableSize.y * _borderTopPercentage).toInt();
    _borderBottom = (_availableSize.y * _borderBottomPercentage).toInt();

    _sizeHeader = Vector2(
      _availableSize.x,
      _availableSize.y * percentageHeader,
    );
    _sizeFooter = Vector2(
      _availableSize.x,
      _availableSize.y * percentageFooter,
    );
    _sizeBlockBoard = Vector2(
      _availableSize.x,
      _availableSize.y - _sizeHeader.y - _sizeFooter.y,
    );
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

  Vector2 get sizeHeader => _sizeHeader;
  Vector2 get sizeFooter => _sizeFooter;
  Vector2 get sizeBlockBoard => _sizeBlockBoard;
}
