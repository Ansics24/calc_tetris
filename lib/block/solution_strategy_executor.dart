import 'dart:async';

import 'package:magic_blocks/block/block_remover.dart';
import 'package:magic_blocks/block/solution_strategy.dart';
import 'package:magic_blocks/block/solution_strategy_singlerun_result.dart';
import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

/// Runs a solution strategy once and removes the solved blocks. The result
/// stream emits the result if blocks were solved and completes afterwards.
class SolutionStrategyExecutor {
  final SolutionStrategy _solutionStrategy;
  final GridModel _gridModel;
  final StreamController<SolutionStrategySinglerunResult> _streamController =
      StreamController<SolutionStrategySinglerunResult>(sync: true);
  final BlockRemover _blockRemover;

  SolutionStrategyExecutor({
    required this._solutionStrategy,
    required this._gridModel,
    BlockRemover? blockRemover,
  }) : _blockRemover = blockRemover ?? BlockRemover();

  Stream<SolutionStrategySinglerunResult> streamOfResults() {
    return _streamController.stream;
  }

  /// Completes after the run is done and the result stream is closed.
  Future<void> runWithTriggeringPositions(
    List<IntVector2> triggeringPositions,
  ) async {
    try {
      final strategyResult = _solutionStrategy.execute(
        _gridModel,
        triggeringPositions: triggeringPositions,
      );
      if (strategyResult.hasSolvedBlocks) {
        final solvedBlocks = strategyResult.solvedBlocks;
        await _blockRemover.removeAll(solvedBlocks);
        _gridModel.removeAll(solvedBlocks);
        _streamController.add(strategyResult);
      }
    } catch (error, stackTrace) {
      _streamController.addError(error, stackTrace);
    } finally {
      _streamController.close();
    }
  }
}
