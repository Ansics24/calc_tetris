import 'dart:async';

import 'package:calc_tetris/block/block_fall_planner.dart';
import 'package:calc_tetris/block/block_remover.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/core/solution/blockfall/block_faller.dart';
import 'package:calc_tetris/core/solution/solution_strategy_singlerun_result.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

/// Runs a solution strategy and removes the solved blocks. Blocks above the
/// removed ones fall down, which may solve further equations (cascade). The
/// result stream emits one result per run and completes after the last run.
class SolutionStrategyExecutor {
  final SolutionStrategy _solutionStrategy;
  final GridModel _gridModel;
  final StreamController<SolutionStrategySinglerunResult> _streamController;
  final BlockRemover _blockRemover;
  final BlockFallPlanner _blockFallPlanner;
  final BlockFaller _blockFaller;

  SolutionStrategyExecutor({
    required this._solutionStrategy,
    required GridModel gridModel,
    BlockRemover? blockRemover,
    BlockFaller? blockFaller,
  }) : _gridModel = gridModel,
       // sync: a result reaches its listeners immediately, i.e. before the
       // next cascade run starts (async delivery would defer it)
       _streamController = StreamController<SolutionStrategySinglerunResult>(
         sync: true,
       ),
       _blockRemover = blockRemover ?? BlockRemover(),
       _blockFallPlanner = BlockFallPlanner(),
       _blockFaller = blockFaller ?? BlockFaller(gridModel: gridModel);

  Stream<SolutionStrategySinglerunResult> streamOfResults() {
    return _streamController.stream;
  }

  /// Completes after all cascades are done and the result stream is closed.
  Future<void> runWithTriggeringPositions(
    List<IntVector2> triggeringPositions,
  ) async {
    try {
      var positions = triggeringPositions;
      // Each fall may form new equations: run again on the moved blocks
      // until nothing is solved or nothing falls anymore.
      while (positions.isNotEmpty) {
        positions = await _runOnce(positions);
      }
    } catch (error, stackTrace) {
      _streamController.addError(error, stackTrace);
    } finally {
      _streamController.close();
    }
  }

  /// Returns the new positions of all blocks that fell down.
  Future<List<IntVector2>> _runOnce(List<IntVector2> positions) async {
    final strategyResult = _solutionStrategy.execute(
      _gridModel,
      triggeringPositions: positions,
    );
    if (!strategyResult.hasSolvedBlocks) {
      return const [];
    }

    final solvedBlocks = strategyResult.solvedBlocks;
    // Plan before removal: the planner needs the positions of solved blocks
    final fallMoves = _blockFallPlanner.plan(_gridModel, solvedBlocks);
    await _blockRemover.removeAll(solvedBlocks);
    _gridModel.removeAll(solvedBlocks);
    _gridModel.applyMoves(fallMoves);
    await _blockFaller.fallAll(fallMoves);
    _streamController.add(strategyResult);

    return fallMoves.map((move) => move.to).toList();
  }
}
