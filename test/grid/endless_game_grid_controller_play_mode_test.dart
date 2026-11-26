import 'package:magic_blocks/block/math/math_single_block_component_factory.dart';
import 'package:magic_blocks/block/math/model/math_number_block.dart';
import 'package:magic_blocks/block/math/seed/compoundblock_model_generator.dart';
import 'package:magic_blocks/block/math/seed/next_block_planner.dart';
import 'package:magic_blocks/block/math/seed/spawn_position_chooser.dart';
import 'package:magic_blocks/block/model/single_block.dart';
import 'package:magic_blocks/grid/endless_game_grid_controller.dart';
import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/grid/play_mode.dart';
import 'package:magic_blocks/grid/power_up_found_listener.dart';
import 'package:magic_blocks/util/int_vector_2.dart';
import 'package:test/test.dart';

import '../support/test_grid.dart';

class _OneCellGenerator implements CompoundblockModelGenerator {
  @override
  List<List<SingleBlock>> generate() => [
    [MathNumberBlock(number: 1)],
  ];
}

class _CenterChooser implements SpawnPositionChooser {
  @override
  IntVector2 choose(List<IntVector2> candidates) => IntVector2(2, 2);
}

const _inUse = PlayMode.powerUpInUse(PowerUpType.cannon);
const _normal = PlayMode.defaultMode();

EndlessGameGridController _controller() {
  final size = IntVector2(5, 5);
  final planner = NextBlockPlanner(generator: _OneCellGenerator());
  final grid = newTestGrid(size, nextBlockPlanner: planner);
  final model = GridModel(size: size, gridComponent: grid)..cellSize = 50;
  return EndlessGameGridController(
    gridModel: model,
    grid: grid,
    solutionStrategy: UnusedStrategy(),
    nextBlockPlanner: planner,
    singleBlockComponentFactory: newComponentFromBlockModel,
    spawnPositionChooser: _CenterChooser(),
  );
}

(int, int) _position(EndlessGameGridController controller) => (
  controller.currentBlockGridPosition!.x,
  controller.currentBlockGridPosition!.y,
);

void _dragAllWays(EndlessGameGridController controller) {
  controller
    ..onBlockDraggedLeft()
    ..onBlockDraggedUp()
    ..onBlockDraggedUp()
    ..onBlockDraggedRight()
    ..onBlockDraggedRight()
    ..onBlockDraggedDown();
}

void main() {
  test('starts in the default mode', () {
    expect(_controller().playMode, _normal);
  });

  group('while a power-up is in use', () {
    test('does not move the block on drags', () {
      final controller = _controller()..spawnNextBlock();
      controller.playMode = _inUse;

      _dragAllWays(controller);

      expect(_position(controller), (2, 2));
    });

    test('does not put the block into the grid', () {
      final controller = _controller()..spawnNextBlock();
      controller.playMode = _inUse;
      final block = controller.currentBlock;

      expect(controller.placeCurrentBlock(), isFalse);
      expect(controller.currentBlock, same(block));
    });

    test('does not let the block be rotated', () {
      final controller = _controller()..spawnNextBlock();
      controller.playMode = _inUse;
      final block = controller.currentBlock!;
      final model = block.model;

      block.rotate();

      expect(block.isLocked, isTrue);
      expect(block.model, same(model));
    });

    test('locks a block that arrives later too', () {
      final controller = _controller()..playMode = _inUse;

      controller.spawnNextBlock();

      expect(controller.currentBlock!.isLocked, isTrue);
      expect(controller.placeCurrentBlock(), isFalse);
    });

    test('draws the current block half transparent', () {
      final controller = _controller()..spawnNextBlock();

      controller.playMode = _inUse;

      expect(controller.currentBlock!.opacity, 0.2);
    });

    test('draws a block that arrives later half transparent too', () {
      final controller = _controller()..playMode = _inUse;

      controller.spawnNextBlock();

      expect(controller.currentBlock!.opacity, 0.2);
    });

    test('can be set without a block', () {
      expect(() => _controller().playMode = _inUse, returnsNormally);
    });
  });

  group('back in the default mode', () {
    test('draws the block fully again', () {
      final controller = _controller()..spawnNextBlock();
      controller.playMode = _inUse;

      controller.playMode = _normal;

      expect(controller.currentBlock!.opacity, 1);
    });

    test('unlocks the block and lets it be placed again', () {
      final controller = _controller()..spawnNextBlock();
      controller.playMode = _inUse;

      controller.playMode = _normal;

      expect(controller.currentBlock!.isLocked, isFalse);
      expect(controller.placeCurrentBlock(), isTrue);
    });

    test('moves the block on drags again', () {
      final controller = _controller()..spawnNextBlock();
      controller.playMode = _inUse;
      controller.playMode = _normal;

      controller.onBlockDraggedLeft();

      expect(_position(controller), (1, 2));
    });
  });

  test('draws blocks fully in the default mode', () {
    final controller = _controller()..spawnNextBlock();

    expect(controller.currentBlock!.opacity, 1);
  });
}
