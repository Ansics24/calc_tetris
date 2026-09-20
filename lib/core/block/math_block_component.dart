import 'package:calc_tetris/core/grid/grid_queryable.dart';
import 'package:flame/components.dart';

class MathBlockComponent extends PositionComponent {
  final GridQueryable _gridQueryable;
  MathBlockComponent({required this._gridQueryable})
    : super(key: ComponentKey.unique());

  GridQueryable get gridQueryable => _gridQueryable;
}
