import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/solution_strategy_singlerun_result.dart';
import 'package:calc_tetris/grid/grid_controller.dart';
import 'package:calc_tetris/grid/grid_round_listener.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';

import '../support/test_grid.dart';

class _OneCellGenerator implements CompoundblockModelGenerator {
  @override
  List<List<SingleBlock>> generate() => [
    [MathNumberBlock(number: 1)],
  ];
}

class _RecordingRoundListener implements GridRoundListener {
  final List<int> points = [];

  @override
  void onRoundFinished(int pointsEarned) => points.add(pointsEarned);
}

GridController _controller({
  GridRoundListener? roundListener,
  bool spawnNextBlockAfterRound = true,
}) {
  final size = IntVector2(5, 5);
  final planner = NextBlockPlanner(generator: _OneCellGenerator());
  final grid = newTestGrid(size, nextBlockPlanner: planner);
  final model = GridModel(size: size, gridComponent: grid)..cellSize = 50;
  return GridController(
    gridModel: model,
    grid: grid,
    solutionStrategy: UnusedStrategy(),
    nextBlockPlanner: planner,
    singleBlockComponentFactory: newComponentFromBlockModel,
    roundListener: roundListener,
    spawnNextBlockAfterRound: spawnNextBlockAfterRound,
  );
}

SolutionStrategySinglerunResult _result(int points) =>
    SolutionStrategySinglerunResult(solvedBlocks: [], pointsEarned: points);

void main() {
  group('round listener', () {
    test('learns the points earned in the round', () {
      final listener = _RecordingRoundListener();
      final controller = _controller(roundListener: listener);

      controller.onStrategyResult(_result(8));
      controller.onStrategyDone();

      expect(listener.points, [8]);
    });

    test('learns 0 points for a round without a solved equation', () {
      final listener = _RecordingRoundListener();
      final controller = _controller(roundListener: listener);

      controller.onStrategyDone();

      expect(listener.points, [0]);
    });

    test('counts the points of every round on its own', () {
      final listener = _RecordingRoundListener();
      final controller = _controller(roundListener: listener);

      controller.onStrategyResult(_result(8));
      controller.onStrategyDone();
      controller.onStrategyDone();

      expect(listener.points, [8, 0]);
    });

    test('is optional', () {
      final controller = _controller();

      expect(controller.onStrategyDone, returnsNormally);
    });
  });

  group('spawning after a round', () {
    test('happens by default', () {
      final controller = _controller();

      controller.onStrategyDone();

      expect(controller.currentBlock, isNotNull);
    });

    test('can be switched off', () {
      final controller = _controller(spawnNextBlockAfterRound: false);

      controller.onStrategyDone();

      expect(controller.currentBlock, isNull);
    });

    test('still informs the listener when switched off', () {
      final listener = _RecordingRoundListener();
      final controller = _controller(
        roundListener: listener,
        spawnNextBlockAfterRound: false,
      );

      controller.onStrategyDone();

      expect(listener.points, [0]);
    });

    test('does not stop the very first spawn when switched off', () {
      final controller = _controller(spawnNextBlockAfterRound: false);

      controller.spawnNextBlock();

      expect(controller.currentBlock, isNotNull);
    });
  });
}
