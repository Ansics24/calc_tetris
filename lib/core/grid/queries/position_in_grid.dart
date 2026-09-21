import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/components.dart';

class PositionInGrid {
  final Component _component;
  final IntVector2 _gridPosition;

  PositionInGrid(this._component, this._gridPosition);

  IntVector2 get gridPosition => _gridPosition;

  Component get component => _component;
}
