import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/grid_single_block_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/solution_strategy.dart';

class ValidEquationSolutionStrategy implements SolutionStrategy {
  @override
  Iterable<GridSingleBlockModel> findSolvedBlocks(
    GridModel gridModel, {
    required List<IntVector2> triggeringPositions,
  }) {
    var connectedBlocks = triggeringPositions.map(
      (pos) => gridModel.findAllConnectedBlocks(pos),
    );
    if (connectedBlocks.isEmpty) {
      return [];
    }
    return connectedBlocks.first.horizontal;
  }
}
