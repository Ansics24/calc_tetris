import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/grid_single_block_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';

abstract interface class SolutionStrategy {
  Iterable<GridSingleBlockModel> findSolvedBlocks(
    GridModel gridModel, {
    required List<IntVector2> triggeringPositions,
  });
}
