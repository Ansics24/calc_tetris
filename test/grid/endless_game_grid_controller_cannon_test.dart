import 'package:calc_tetris/block/math/math_equals_block_component.dart';
import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/endless_game_grid_controller.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/grid/play_mode.dart';
import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/grid/power_up_used_listener.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';

import '../support/test_grid.dart';

class _OneCellGenerator implements CompoundblockModelGenerator {
  @override
  List<List<SingleBlock>> generate() => [
    [MathNumberBlock(number: 1)],
  ];
}

class _RecordingListener implements PowerUpUsedListener {
  final List<PowerUpType> used = [];

  @override
  void onPowerUpUsed(PowerUpType type) => used.add(type);
}

class _Setup {
  final EndlessGameGridController controller;
  final GridModel model;
  final _RecordingListener listener;

  _Setup(this.controller, this.model, this.listener);

  void put(int x, int y) => model.addSingleBlock(
    'P',
    MathEqualsBlockComponent(model: MathEqualsBlock()),
    IntVector2(x, y),
  );

  bool occupied(int x, int y) =>
      model.findExistingBlockAt(IntVector2(x, y)) != null;
}

_Setup _setup({bool cannonInUse = true}) {
  final size = IntVector2(5, 5);
  final planner = NextBlockPlanner(generator: _OneCellGenerator());
  final grid = newTestGrid(size, nextBlockPlanner: planner);
  final model = GridModel(size: size, gridComponent: grid)..cellSize = 50;
  final listener = _RecordingListener();
  final controller = EndlessGameGridController(
    gridModel: model,
    grid: grid,
    solutionStrategy: UnusedStrategy(),
    nextBlockPlanner: planner,
    singleBlockComponentFactory: newComponentFromBlockModel,
    powerUpUsedListener: listener,
  );
  if (cannonInUse) {
    controller.playMode = const PlayMode.powerUpInUse(PowerUpType.cannon);
  }
  return _Setup(controller, model, listener);
}

void main() {
  group('a shot with the cannon', () {
    test('removes the block it hits', () {
      final setup = _setup()
        ..put(1, 2)
        ..put(2, 2);

      setup.controller.onCellTapped(IntVector2(1, 2));

      expect(setup.occupied(1, 2), isFalse);
      expect(setup.occupied(2, 2), isTrue);
    });

    test('is counted when it hits', () {
      final setup = _setup()..put(1, 2);

      setup.controller.onCellTapped(IntVector2(1, 2));

      expect(setup.listener.used, [PowerUpType.cannon]);
    });

    test('is counted when it misses, and changes nothing', () {
      final setup = _setup()..put(1, 2);

      setup.controller.onCellTapped(IntVector2(3, 3));

      expect(setup.listener.used, [PowerUpType.cannon]);
      expect(setup.occupied(1, 2), isTrue);
    });

    test('counts every tap', () {
      final setup = _setup();

      setup.controller
        ..onCellTapped(IntVector2(0, 0))
        ..onCellTapped(IntVector2(1, 0));

      expect(setup.listener.used, hasLength(2));
    });

    test('ignores taps outside of the grid', () {
      final setup = _setup();

      setup.controller
        ..onCellTapped(IntVector2(-1, 0))
        ..onCellTapped(IntVector2(5, 5));

      expect(setup.listener.used, isEmpty);
    });
  });

  group('in the default mode', () {
    test('a tap does not shoot', () {
      final setup = _setup(cannonInUse: false)..put(1, 2);

      setup.controller.onCellTapped(IntVector2(1, 2));

      expect(setup.occupied(1, 2), isTrue);
      expect(setup.listener.used, isEmpty);
    });
  });

  test('the cannon has 8 shots', () {
    expect(PowerUpType.cannon.uses, 8);
  });
}
