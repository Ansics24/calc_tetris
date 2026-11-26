import 'dart:math';

import 'package:magic_blocks/block/math/math_equals_block_component.dart';
import 'package:magic_blocks/block/math/math_single_block_component_factory.dart';
import 'package:magic_blocks/block/math/model/math_equals_block.dart';
import 'package:magic_blocks/block/math/model/math_number_block.dart';
import 'package:magic_blocks/block/math/seed/compoundblock_model_generator.dart';
import 'package:magic_blocks/block/math/seed/next_block_planner.dart';
import 'package:magic_blocks/block/model/single_block.dart';
import 'package:magic_blocks/block/solution_strategy_singlerun_result.dart';
import 'package:magic_blocks/grid/endless_game_grid_controller.dart';
import 'package:magic_blocks/grid/grid.dart';
import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/grid/power_up_found_listener.dart';
import 'package:magic_blocks/util/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

import '../support/test_grid.dart';

class _OneCellGenerator implements CompoundblockModelGenerator {
  @override
  List<List<SingleBlock>> generate() => [
    [MathNumberBlock(number: 1)],
  ];
}

/// A random source that always rolls [value].
class _FixedRandom implements Random {
  final double value;

  _FixedRandom(this.value);

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}

class _RecordingListener implements PowerUpFoundListener {
  final List<PowerUpType> types = [];
  final List<Vector2> positions = [];

  @override
  void onPowerUpFound(PowerUpType type, Vector2 foundPositionAbsoluteCenter) {
    types.add(type);
    positions.add(foundPositionAbsoluteCenter);
  }
}

class _Setup {
  final EndlessGameGridController controller;
  final GridModel model;
  final Grid grid;

  _Setup(this.controller, this.model, this.grid);

  /// A result for equations made of the blocks at [positions].
  SolutionStrategySinglerunResult solved(
    List<IntVector2> positions, {
    int points = 6,
  }) {
    for (final position in positions) {
      model.addSingleBlock(
        'P',
        MathEqualsBlockComponent(model: MathEqualsBlock()),
        position,
      );
    }
    return SolutionStrategySinglerunResult(
      solvedBlocks: positions
          .map((p) => model.findExistingBlockAt(p)!)
          .toList(),
      pointsEarned: points,
    );
  }
}

/// A controller with a listener. Without [chances] the default ones are used.
_Setup _setup({
  Map<PowerUpType, double>? chances,
  double roll = 0,
  PowerUpFoundListener? listener,
}) {
  final size = IntVector2(5, 5);
  final planner = NextBlockPlanner(generator: _OneCellGenerator());
  final grid = newTestGrid(size, nextBlockPlanner: planner);
  final model = GridModel(size: size, gridComponent: grid)..cellSize = 50;
  final random = _FixedRandom(roll);
  final controller = chances == null
      ? EndlessGameGridController(
          gridModel: model,
          grid: grid,
          solutionStrategy: UnusedStrategy(),
          nextBlockPlanner: planner,
          singleBlockComponentFactory: newComponentFromBlockModel,
          powerUpFoundListener: listener,
          random: random,
        )
      : EndlessGameGridController(
          gridModel: model,
          grid: grid,
          solutionStrategy: UnusedStrategy(),
          nextBlockPlanner: planner,
          singleBlockComponentFactory: newComponentFromBlockModel,
          powerUpFoundListener: listener,
          powerUpFindChances: chances,
          random: random,
        );
  return _Setup(controller, model, grid);
}

SolutionStrategySinglerunResult _points(int points) =>
    SolutionStrategySinglerunResult(solvedBlocks: [], pointsEarned: points);

void main() {
  group('chances of finding power-ups', () {
    test('are 20 percent for a cannon by default', () {
      expect(EndlessGameGridController.defaultPowerUpFindChances, {
        PowerUpType.cannon: 0.2,
      });
    });

    test('finds a cannon by default when the roll is below 0.2', () {
      final listener = _RecordingListener();
      final setup = _setup(roll: 0.19, listener: listener);

      setup.controller.onStrategyResult(_points(6));

      expect(listener.types, [PowerUpType.cannon]);
    });

    test('finds nothing by default when the roll is 0.2 or higher', () {
      final listener = _RecordingListener();
      final setup = _setup(roll: 0.2, listener: listener);

      setup.controller.onStrategyResult(_points(6));

      expect(listener.types, isEmpty);
    });

    test('can be configured', () {
      final found = _RecordingListener();
      final notFound = _RecordingListener();

      _setup(
        chances: {PowerUpType.cannon: 0.5},
        roll: 0.49,
        listener: found,
      ).controller.onStrategyResult(_points(6));
      _setup(
        chances: {PowerUpType.cannon: 0.5},
        roll: 0.5,
        listener: notFound,
      ).controller.onStrategyResult(_points(6));

      expect(found.types, hasLength(1));
      expect(notFound.types, isEmpty);
    });

    test('is a sure find with 1', () {
      final listener = _RecordingListener();
      final setup = _setup(
        chances: {PowerUpType.cannon: 1},
        roll: 0.999999,
        listener: listener,
      );

      setup.controller.onStrategyResult(_points(6));

      expect(listener.types, hasLength(1));
    });

    test('is no find at all with 0', () {
      final listener = _RecordingListener();
      final setup = _setup(
        chances: {PowerUpType.cannon: 0},
        roll: 0,
        listener: listener,
      );

      setup.controller.onStrategyResult(_points(6));

      expect(listener.types, isEmpty);
    });

    test('must be between 0 and 1', () {
      expect(
        () => _setup(chances: {PowerUpType.cannon: -0.1}),
        throwsArgumentError,
      );
      expect(
        () => _setup(chances: {PowerUpType.cannon: 1.1}),
        throwsArgumentError,
      );
    });

    test(
      'replace the defaults, a power-up without a chance is never found',
      () {
        final listener = _RecordingListener();
        final setup = _setup(chances: {}, roll: 0, listener: listener);

        setup.controller.onStrategyResult(_points(6));

        expect(listener.types, isEmpty);
      },
    );
  });

  group('finding a cannon', () {
    test('is rolled for every solved result', () {
      final listener = _RecordingListener();
      final setup = _setup(
        chances: {PowerUpType.cannon: 1},
        listener: listener,
      );

      setup.controller.onStrategyResult(_points(6));
      setup.controller.onStrategyResult(_points(8));

      expect(listener.types, [PowerUpType.cannon, PowerUpType.cannon]);
    });

    test('does not happen without points', () {
      final listener = _RecordingListener();
      final setup = _setup(
        chances: {PowerUpType.cannon: 1},
        listener: listener,
      );

      setup.controller.onStrategyResult(_points(0));

      expect(listener.types, isEmpty);
    });

    test('is reported at the center of the solved blocks', () {
      final listener = _RecordingListener();
      final setup = _setup(
        chances: {PowerUpType.cannon: 1},
        listener: listener,
      );

      setup.controller.onStrategyResult(
        setup.solved([IntVector2(1, 1), IntVector2(2, 1), IntVector2(3, 1)]),
      );

      // the grid is not mounted, so its cells have no size yet: the center
      // is the average of the top left corners (50..150, 50)
      expect(listener.positions.single, Vector2(100, 50));
    });

    test('is reported at the grid center when no block is known', () {
      final listener = _RecordingListener();
      final setup = _setup(
        chances: {PowerUpType.cannon: 1},
        listener: listener,
      );

      setup.controller.onStrategyResult(_points(6));

      expect(listener.positions.single, setup.grid.absoluteCenter);
    });

    test('does not change the points', () {
      final setup = _setup(
        chances: {PowerUpType.cannon: 1},
        listener: _RecordingListener(),
      );

      expect(
        () => setup.controller.onStrategyResult(_points(6)),
        returnsNormally,
      );
    });

    test('is optional, nobody has to listen', () {
      final setup = _setup(chances: {PowerUpType.cannon: 1});

      expect(
        () => setup.controller.onStrategyResult(_points(6)),
        returnsNormally,
      );
    });
  });
}
