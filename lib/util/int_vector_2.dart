class IntVector2 {
  final int _x;
  final int _y;

  IntVector2(this._x, this._y);

  IntVector2.square(this._x) : _y = _x;

  int get x => _x;

  int get y => _y;

  IntVector2 addY(int y) {
    return IntVector2(_x, _y + y);
  }

  IntVector2 addX(int x) {
    return IntVector2(_x + x, _y);
  }

  IntVector2 add(int x, int y) {
    return IntVector2(_x + x, _y + y);
  }

  @override
  String toString() {
    return '($x / $y)';
  }
}
