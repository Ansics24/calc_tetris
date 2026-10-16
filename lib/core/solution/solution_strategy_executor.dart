import 'dart:async';

import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/solution/blockremove/block_remover.dart';
import 'package:calc_tetris/core/solution/solution_strategy.dart';
import 'package:calc_tetris/core/solution/solution_strategy_singlerun_result.dart';

class SolutionStrategyExecutor {
  final SolutionStrategy _solutionStrategy;
  final GridModel _gridModel;
  final StreamController<SolutionStrategySinglerunResult> _streamController;
  final BlockRemover _blockRemover;

  SolutionStrategyExecutor({
    required this._solutionStrategy,
    required this._gridModel,
  }) : _streamController = StreamController<SolutionStrategySinglerunResult>(),
       _blockRemover = BlockRemover();

  Stream<SolutionStrategySinglerunResult> streamOfResults() {
    return _streamController.stream;
  }

  void runWithTriggeringPositions(
    List<IntVector2> triggeringPositions,
  ) async {
    final strategyResult = _solutionStrategy.execute(
      _gridModel,
      triggeringPositions: triggeringPositions,
    );
    if (strategyResult.hasSolvedBlocks) {
      var solvedBlocks = strategyResult.solvedBlocks;
      await _blockRemover.removeAll(solvedBlocks);
      _gridModel.removeAll(solvedBlocks);
      _streamController.add(strategyResult);
    }
    _streamController.close();
  }
}
