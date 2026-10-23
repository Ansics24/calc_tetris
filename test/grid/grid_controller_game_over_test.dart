import 'package:calc_tetris/block/math/math_number_block_component.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/model/math_single_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/start_column_chooser.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_controller.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

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
class _FirstCandidateChooser implements StartColumnChooser {
  List<int>? lastCandidates;

  @override
  int choose({
    required int blockWidth,
    required int gridWidth,
    List<int>? candidates,
  }) {
    lastCandidates = candidates;
    return candidates!.first;
  }
}

/// Never used in these tests, as no block lands.
class _UnusedStrategy implements SolutionStrategy {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('strategy must not be used');
}

({GridController controller, GridModel model, NextBlockPlanner planner})
_setUp({
  required GameOverListener listener,
  required StartColumnChooser chooser,
  Set<(int, int)> blocked = const {},
}) {
  final size = IntVector2(5, 5);
  final grid = Grid(blockCount: size);
  final model = GridModel(size: size, gridComponent: grid)..cellSize = 50;
  for (final (x, y) in blocked) {
    model.addSingleBlock(
      Uuid().toString(),
      MathNumberBlockComponent(model: MathNumberBlock(number: 9)),
      IntVector2(x, y),
    );
  }
  final planner = NextBlockPlanner(generator: _TwoWideGenerator());
  final controller = GridController(
    gridModel: model,
    grid: grid,
    solutionStrategy: _UnusedStrategy(),
    nextBlockPlanner: planner,
    startColumnChooser: chooser,
    gameOverListener: listener,
  );
  return (controller: controller, model: model, planner: planner);
}

void main() {
  test('offers only columns whose top cells are free as candidates', () {
    final chooser = _FirstCandidateChooser();
    final setUp = _setUp(
      listener: _RecordingListener(),
      chooser: chooser,
      blocked: {(0, 0), (3, 0)},
    );

    setUp.controller.spawnNextBlock();

    // block is 2 wide: c=0 hits (0,0), c=2 and c=3 hit (3,0)
    expect(chooser.lastCandidates, [1]);
    expect(setUp.controller.currentBlockGridPosition!.x, 1);
  });

  test('does not signal game over while a free column exists', () {
    final listener = _RecordingListener();
    final setUp = _setUp(
      listener: listener,
      chooser: _FirstCandidateChooser(),
      blocked: {(0, 0)},
    );

    setUp.controller.spawnNextBlock();

    expect(listener.calls, 0);
    expect(setUp.controller.currentBlock, isNotNull);
  });

  test('signals game over once when the block fits nowhere', () {
    final listener = _RecordingListener();
    final setUp = _setUp(
      listener: listener,
      chooser: _FirstCandidateChooser(),
      blocked: {(1, 0), (3, 0)},
    );

    setUp.controller.spawnNextBlock();

    expect(listener.calls, 1);
    expect(setUp.controller.currentBlock, isNull);
  });

  test('keeps the upcoming block when the game is over', () {
    final setUp = _setUp(
      listener: _RecordingListener(),
      chooser: _FirstCandidateChooser(),
      blocked: {(1, 0), (3, 0)},
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
      blocked: {(1, 0), (3, 0)},
    );
    setUp.controller.spawnNextBlock();

    setUp.controller.spawnNextBlock();
    setUp.controller.moveBlockLeft();
    setUp.controller.moveBlockRight();
    setUp.controller.fallBlockDown();
    setUp.controller.moveBlockDownByOne();

    expect(listener.calls, 1);
    expect(setUp.controller.currentBlock, isNull);
    expect(setUp.controller.isGameOver, isTrue);
  });

  test('works without a game over listener', () {
    final controller = _setUp(
      listener: _RecordingListener(),
      chooser: _FirstCandidateChooser(),
      blocked: {(1, 0), (3, 0)},
    ).controller;

    expect(controller.spawnNextBlock, returnsNormally);
  });
}
