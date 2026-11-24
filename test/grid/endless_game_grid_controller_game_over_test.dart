import 'package:calc_tetris/block/math/math_number_block_component.dart';
import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/model/math_single_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/spawn_position_chooser.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/grid/endless_game_grid_controller.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../support/test_grid.dart';

class _TwoWideGenerator implements CompoundblockModelGenerator {
  @override
  List<List<MathSingleBlock>> generate() => [
    [MathNumberBlock(number: 1)],
    [MathNumberBlock(number: 2)],
  ];
}

class _RecordingListener implements GameOverListener {
  int calls = 0;

  @override
  void onGameOver() => calls++;
}

/// Always picks the first of the offered candidates.
class _FirstCandidateChooser implements SpawnPositionChooser {
  List<IntVector2>? lastCandidates;

  @override
  IntVector2 choose(List<IntVector2> candidates) {
    lastCandidates = candidates;
    return candidates.first;
  }
}

/// Never used in these tests, as no block lands.
class _UnusedStrategy implements SolutionStrategy {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('strategy must not be used');
}

({
  EndlessGameGridController controller,
  GridModel model,
  NextBlockPlanner planner,
})
_setUp({
  required GameOverListener listener,
  required SpawnPositionChooser chooser,
  Set<(int, int)> blocked = const {},
}) {
  final size = IntVector2(5, 5);
  final grid = newTestGrid(size);
  final model = GridModel(size: size, gridComponent: grid)..cellSize = 50;
  for (final (x, y) in blocked) {
    model.addSingleBlock(
      Uuid().toString(),
      MathNumberBlockComponent(model: MathNumberBlock(number: 9)),
      IntVector2(x, y),
    );
  }
  final planner = NextBlockPlanner(generator: _TwoWideGenerator());
  final controller = EndlessGameGridController(
    gridModel: model,
    grid: grid,
    solutionStrategy: _UnusedStrategy(),
    nextBlockPlanner: planner,
    singleBlockComponentFactory: newComponentFromBlockModel,
    spawnPositionChooser: chooser,
    gameOverListener: listener,
  );
  return (controller: controller, model: model, planner: planner);
}

/// Blocks the columns 1 and 3 completely. A 2 wide block fits nowhere then,
/// as the remaining free columns 0, 2 and 4 are never adjacent.
Set<(int, int)> _noRoomForTwoWideBlock() => {
  for (var y = 0; y < 5; y++) ...[(1, y), (3, y)],
};

void main() {
  test('offers border positions other than the top as candidates', () {
    final chooser = _FirstCandidateChooser();
    final setUp = _setUp(
      listener: _RecordingListener(),
      chooser: chooser,
      blocked: {for (var x = 0; x < 5; x++) (x, 0)},
    );

    setUp.controller.spawnNextBlock();

    final candidates = chooser.lastCandidates!;
    expect(candidates, isNotEmpty);
    expect(candidates.every((p) => p.y > 0), isTrue);
    expect(setUp.controller.currentBlock, isNotNull);
  });

  test('spawns inside the grid when the whole border is blocked', () {
    final listener = _RecordingListener();
    final setUp = _setUp(
      listener: listener,
      chooser: _FirstCandidateChooser(),
      blocked: {
        for (var x = 0; x < 5; x++)
          for (var y = 0; y < 5; y++)
            if (x == 0 || y == 0 || x == 4 || y == 4) (x, y),
      },
    );

    setUp.controller.spawnNextBlock();

    final position = setUp.controller.currentBlockGridPosition!;
    expect(position.x, inInclusiveRange(1, 2));
    expect(position.y, inInclusiveRange(1, 3));
    expect(listener.calls, 0);
  });

  test('does not signal game over while any position is free', () {
    final listener = _RecordingListener();
    final setUp = _setUp(
      listener: listener,
      chooser: _FirstCandidateChooser(),
      blocked: _noRoomForTwoWideBlock()..remove((3, 2)),
    );

    setUp.controller.spawnNextBlock();

    // (3,2) is free now, so the block fits at the right border
    expect(listener.calls, 0);
    expect(setUp.controller.currentBlockGridPosition!.x, 3);
    expect(setUp.controller.currentBlockGridPosition!.y, 2);
  });

  test('signals game over once when the block fits nowhere', () {
    final listener = _RecordingListener();
    final setUp = _setUp(
      listener: listener,
      chooser: _FirstCandidateChooser(),
      blocked: _noRoomForTwoWideBlock(),
    );

    setUp.controller.spawnNextBlock();

    expect(listener.calls, 1);
    expect(setUp.controller.currentBlock, isNull);
  });

  test('keeps the upcoming block when the game is over', () {
    final setUp = _setUp(
      listener: _RecordingListener(),
      chooser: _FirstCandidateChooser(),
      blocked: _noRoomForTwoWideBlock(),
    );
    final upcoming = setUp.planner.upcoming;

    setUp.controller.spawnNextBlock();

    expect(identical(setUp.planner.upcoming, upcoming), isTrue);
  });

  test('stops working after game over', () {
    final listener = _RecordingListener();
    final setUp = _setUp(
      listener: listener,
      chooser: _FirstCandidateChooser(),
      blocked: _noRoomForTwoWideBlock(),
    );
    setUp.controller.spawnNextBlock();

    setUp.controller.spawnNextBlock();
    setUp.controller.onBlockDraggedLeft();
    setUp.controller.onBlockDraggedRight();

    expect(listener.calls, 1);
    expect(setUp.controller.currentBlock, isNull);
    expect(setUp.controller.isGameOver, isTrue);
  });

  test('works without a game over listener', () {
    final controller = _setUp(
      listener: _RecordingListener(),
      chooser: _FirstCandidateChooser(),
      blocked: _noRoomForTwoWideBlock(),
    ).controller;

    expect(controller.spawnNextBlock, returnsNormally);
  });
}
