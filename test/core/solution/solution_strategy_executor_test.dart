import 'package:calc_tetris/core/block/math_equals_block_component.dart';
import 'package:calc_tetris/core/block/model/math_equals_block.dart';
import 'package:calc_tetris/core/grid/block_move.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/grid_single_block_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/solution/blockfall/block_faller.dart';
import 'package:calc_tetris/core/solution/blockremove/block_remover.dart';
import 'package:calc_tetris/core/solution/solution_strategy.dart';
import 'package:calc_tetris/core/solution/solution_strategy_executor.dart';
import 'package:calc_tetris/core/solution/solution_strategy_singlerun_result.dart';
import 'package:test/test.dart';

/// Grid coordinates: x = column, y = row (top to bottom). Blocks fall to
/// higher y. In a 5x5 grid the bottom row is y = 4.

typedef _Step =
    SolutionStrategySinglerunResult Function(
      GridModel grid,
      List<IntVector2> triggeringPositions,
    );

/// Returns the scripted result per call. Once the script is used up it
/// returns an empty result (= nothing solved).
class _ScriptedStrategy implements SolutionStrategy {
  final GridModel grid;
  final List<_Step> script;
  final List<List<String>> triggeringPositionsPerCall = [];

  _ScriptedStrategy(this.grid, this.script);

  int get callCount => triggeringPositionsPerCall.length;

  @override
  SolutionStrategySinglerunResult execute(
    GridModel gridModel, {
    required List<IntVector2> triggeringPositions,
  }) {
    final index = callCount;
    triggeringPositionsPerCall.add(
      triggeringPositions.map((p) => p.toString()).toList()..sort(),
    );
    if (index >= script.length) {
      return SolutionStrategySinglerunResult.empty();
    }
    return script[index](gridModel, triggeringPositions);
  }
}

class _InstantBlockRemover implements BlockRemover {
  @override
  Future<void> removeAll(Iterable<GridSingleBlockModel> modelsToRemove) async {
    await Future<void>.delayed(Duration.zero); // like a real async animation
  }
}

class _InstantBlockFaller implements BlockFaller {
  @override
  Future<void> fallAll(Iterable<BlockMove> moves) async {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late GridModel grid;
  late List<String> events;

  setUp(() {
    grid = GridModel(
      size: IntVector2(5, 5),
      gridComponent: Grid(blockCount: IntVector2(5, 5)),
    );
    grid.cellSize = 50;
    events = [];
  });

  void put(String placementId, int x, int y) {
    grid.addSingleBlock(
      placementId,
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(x, y),
    );
  }

  SolutionStrategySinglerunResult solved(List<IntVector2> positions) {
    return SolutionStrategySinglerunResult(
      solvedBlocks: positions.map((p) => grid.findExistingBlockAt(p)!).toList(),
      pointsEarned: positions.length,
    );
  }

  Future<_ScriptedStrategy> run(
    List<_Step> script,
    List<IntVector2> initialTriggers,
  ) async {
    final strategy = _ScriptedStrategy(grid, script);
    final executor = SolutionStrategyExecutor(
      solutionStrategy: strategy,
      gridModel: grid,
      blockRemover: _InstantBlockRemover(),
      blockFaller: _InstantBlockFaller(),
    );
    executor.streamOfResults().listen(
      (_) => events.add('result'),
      onDone: () => events.add('done'),
    );
    await executor.runWithTriggeringPositions(initialTriggers);
    await Future<void>.delayed(Duration.zero); // let the stream deliver 'done'
    return strategy;
  }

  group('without cascade', () {
    test('nothing solved => no result, stream completes', () async {
      put('A', 0, 4);

      final strategy = await run([], [IntVector2(0, 4)]);

      expect(strategy.callCount, 1);
      expect(events, ['done']);
    });

    test('solved but nothing falls => single run, no further run', () async {
      put('A', 0, 4);

      final strategy = await run(
        [
          (g, t) => solved([IntVector2(0, 4)]),
        ],
        [IntVector2(0, 4)],
      );

      expect(strategy.callCount, 1);
      expect(events, ['result', 'done']);
    });
  });

  group('cascade', () {
    test('blocks fell => strategy runs again on the new positions', () async {
      put('A', 0, 4); // solved
      put('B', 0, 3); // falls to (0,4)

      final strategy = await run(
        [
          (g, t) => solved([IntVector2(0, 4)]),
        ],
        [IntVector2(0, 4)],
      );

      expect(strategy.callCount, 2);
      expect(strategy.triggeringPositionsPerCall[1], ['(0 / 4)']);
      expect(events, ['result', 'done']); // 2nd run solved nothing
    });

    test(
      'all fallen blocks are triggering positions of the next run',
      () async {
        put('A', 0, 4); // solved
        put('B', 0, 3);
        put('C', 0, 2);

        final strategy = await run(
          [
            (g, t) => solved([IntVector2(0, 4)]),
          ],
          [IntVector2(0, 4)],
        );

        expect(strategy.triggeringPositionsPerCall[1], [
          '(0 / 3)',
          '(0 / 4)',
        ]);
      },
    );

    test('second run solves => second result, done only afterwards', () async {
      put('A', 0, 4); // solved in run 1
      put('B', 0, 3); // falls to (0,4), solved in run 2

      final strategy = await run(
        [
          (g, t) => solved([IntVector2(0, 4)]),
          (g, t) => solved([IntVector2(0, 4)]),
        ],
        [IntVector2(0, 4)],
      );

      expect(strategy.callCount, 2); // nothing fell after run 2
      expect(events, ['result', 'result', 'done']);
      expect(grid.findExistingBlockAt(IntVector2(0, 4)), isNull);
    });

    test('multi level cascade: runs until nothing falls anymore', () async {
      put('A', 0, 4); // solved in run 1
      put('B', 0, 3); // falls to (0,4), solved in run 2
      put('C', 0, 2); // falls to (0,3) then (0,4), solved in run 3

      final strategy = await run(
        [
          (g, t) => solved([IntVector2(0, 4)]),
          (g, t) => solved([IntVector2(0, 4)]),
          (g, t) => solved([IntVector2(0, 4)]),
        ],
        [IntVector2(0, 4)],
      );

      expect(strategy.callCount, 3);
      expect(events, ['result', 'result', 'result', 'done']);
    });

    test('stream is not completed while a cascade is still running', () async {
      put('A', 0, 4);
      put('B', 0, 3);
      final strategy = _ScriptedStrategy(grid, [
        (g, t) => solved([IntVector2(0, 4)]),
        (g, t) {
          // The stream must still be open while the cascade run executes.
          events.add('cascade-run');
          return solved([IntVector2(0, 4)]);
        },
      ]);
      final executor = SolutionStrategyExecutor(
        solutionStrategy: strategy,
        gridModel: grid,
        blockRemover: _InstantBlockRemover(),
        blockFaller: _InstantBlockFaller(),
      );
      executor.streamOfResults().listen(
        (_) => events.add('result'),
        onDone: () => events.add('done'),
      );

      await executor.runWithTriggeringPositions([IntVector2(0, 4)]);
      await Future<void>.delayed(Duration.zero);

      expect(events, ['result', 'cascade-run', 'result', 'done']);
    });
  });
}
