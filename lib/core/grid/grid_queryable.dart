import 'package:calc_tetris/core/block/math_block_model.dart';
import 'package:calc_tetris/core/block/math_compound_block.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';

abstract interface class GridQueryable {
  bool hasBlocksUnder(MathCompoundBlock compoundBlock);

  MathBlockModel? findExistingBlockAt(IntVector2 positionInGrid);
}
