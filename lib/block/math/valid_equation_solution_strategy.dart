import 'package:calc_tetris/block/math/model/equation.dart';
import 'package:calc_tetris/block/math/scoring/digit_multiplier_score_calculator.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/core/scoring/score_calculator.dart';
import 'package:calc_tetris/core/solution/solution_strategy_singlerun_result.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/grid/model/grid_single_block_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

class ValidEquationSolutionStrategy implements SolutionStrategy {
  final ScoreCalculator _scoreCalculator;

  ValidEquationSolutionStrategy({ScoreCalculator? scoreCalculator})
    : _scoreCalculator = scoreCalculator ?? DigitMultiplierScoreCalculator();

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
    final equations = _distinct(
      connectedBlocks
          .map((cb) => cb.horizontal)
          .followedBy(connectedBlocks.map((cb) => cb.vertical))
          .map(findBiggestValidEquation)
          .where((blocks) => blocks.isNotEmpty),
    );
    return SolutionStrategySinglerunResult(
      solvedBlocks: equations.expand((blocks) => blocks).toSet().toList(),
      pointsEarned: equations.map(_score).fold(0, (sum, p) => sum + p),
    );
  }

  int _score(List<GridSingleBlockModel> blocks) => _scoreCalculator.calculate(
    Equation.fromBlocks(blocks.map((b) => b.component.model)),
  );

  List<List<GridSingleBlockModel>> _distinct(
    Iterable<Iterable<GridSingleBlockModel>> equations,
  ) {
    final result = <List<GridSingleBlockModel>>[];
    for (final blocks in equations.map((e) => e.toList())) {
      if (!result.any((known) => _sameBlocks(known, blocks))) {
        result.add(blocks);
      }
    }
    return result;
  }

  bool _sameBlocks(
    List<GridSingleBlockModel> a,
    List<GridSingleBlockModel> b,
  ) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) {
        return false;
      }
    }
    return true;
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
