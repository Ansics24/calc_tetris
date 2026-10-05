import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';

abstract interface class PositionInGridAware {
  IntVector2? positionInGrid(MathBlockComponent component);
}
