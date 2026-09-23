import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';

abstract interface class GridQueryable {
  MathSingleBlockComponent? findExistingBlockAt(IntVector2 positionInGrid);
}
