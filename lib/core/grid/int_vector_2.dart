class IntVector2 {
  final int _x;
  final int _y;

  IntVector2(this._x, this._y);

  int get x => _x;
  int get y => _y;

  @override
  String toString() {
    return '($x / $y)';
  }
}
