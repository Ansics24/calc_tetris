import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/grid_single_block_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/math/equation.dart';
import 'package:calc_tetris/core/solution/solution_strategy.dart';
import 'package:calc_tetris/core/solution/solution_strategy_singlerun_result.dart';

class ValidEquationSolutionStrategy implements SolutionStrategy {
  @override
  SolutionStrategySinglerunResult execute(
    GridModel gridModel, {
    required List<IntVector2> triggeringPositions,
  }) {
    var connectedBlocks = triggeringPositions.map(
      (pos) => gridModel.findAllConnectedBlocks(pos),
    );
    if (connectedBlocks.isEmpty) {
      return SolutionStrategySinglerunResult.empty();
    }
    final eqBlocksHorizonal = connectedBlocks.expand(
      (cb) => findBiggestValidEquation(cb.horizontal),
    );
    final eqBlocksVertical = connectedBlocks.expand(
      (cb) => findBiggestValidEquation(cb.vertical),
    );
    return SolutionStrategySinglerunResult(
      solvedBlocks: eqBlocksHorizonal
          .followedBy(eqBlocksVertical)
          .toSet()
          .toList(),
      pointsEarned: 0,
    );
  }

  Iterable<GridSingleBlockModel> findBiggestValidEquation(
    Iterable<GridSingleBlockModel> blocks,
  ) {
    for (
      var eqLength = blocks.length;
      eqLength >= Equation.minLength;
      eqLength--
    ) {
      for (var i = blocks.length - eqLength; i >= 0; i--) {
        var equationBlocks = blocks.skip(i).take(eqLength);
        var equation = Equation.fromBlocks(
          equationBlocks.map((b) => b.component.model),
        );
        if (equation.isCorrect()) {
          return equationBlocks;
        }
      }
    }
    return List.empty();
  }
}
