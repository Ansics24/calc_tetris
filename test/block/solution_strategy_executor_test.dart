import 'package:magic_blocks/block/block_remover.dart';
import 'package:magic_blocks/block/math/math_equals_block_component.dart';
import 'package:magic_blocks/block/math/model/math_equals_block.dart';
import 'package:magic_blocks/block/solution_strategy.dart';
import 'package:magic_blocks/block/solution_strategy_executor.dart';
import 'package:magic_blocks/block/solution_strategy_singlerun_result.dart';
import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/grid/model/grid_single_block_model.dart';
import 'package:magic_blocks/util/int_vector_2.dart';
import 'package:test/test.dart';

import '../support/test_grid.dart';

/// Returns the scripted result of the single run, an empty one if the script
/// is empty (= nothing solved).
class _ScriptedStrategy implements SolutionStrategy {
  final SolutionStrategySinglerunResult? result;
  final List<List<String>> triggeringPositionsPerCall = [];

  _ScriptedStrategy(this.result);

  int get callCount => triggeringPositionsPerCall.length;

  @override
  SolutionStrategySinglerunResult execute(
    GridModel gridModel, {
    required List<IntVector2> triggeringPositions,
  }) {
    triggeringPositionsPerCall.add(
      triggeringPositions.map((p) => p.toString()).toList()..sort(),
    );
    return result ?? SolutionStrategySinglerunResult.empty();
  }
}

class _InstantBlockRemover implements BlockRemover {
  @override
  Future<void> removeAll(Iterable<GridSingleBlockModel> modelsToRemove) async {
    await Future<void>.delayed(Duration.zero); // like a real async animation
  }
}

void main() {
  late GridModel grid;
  late List<String> events;

  setUp(() {
    grid = GridModel(
      size: IntVector2(5, 5),
      gridComponent: newTestGrid(IntVector2(5, 5)),
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
    SolutionStrategySinglerunResult? result,
    List<IntVector2> triggers,
  ) async {
    final strategy = _ScriptedStrategy(result);
    final executor = SolutionStrategyExecutor(
      solutionStrategy: strategy,
      gridModel: grid,
      blockRemover: _InstantBlockRemover(),
    );
    executor.streamOfResults().listen(
      (_) => events.add('result'),
      onDone: () => events.add('done'),
    );
    await executor.runWithTriggeringPositions(triggers);
    await Future<void>.delayed(Duration.zero); // let the stream deliver 'done'
    return strategy;
  }

  test('nothing solved => no result, stream completes', () async {
    put("P", 0, 4);

    final strategy = await run(null, [IntVector2(0, 4)]);

    expect(strategy.callCount, 1);
    expect(events, ['done']);
  });

  test('solved => one result, solved blocks removed, single run', () async {
    put("P", 0, 4);
    put("P", 0, 3);

    final strategy = await run(solved([IntVector2(0, 4)]), [IntVector2(0, 4)]);

    expect(strategy.callCount, 1);
    expect(events, ['result', 'done']);
    expect(grid.findExistingBlockAt(IntVector2(0, 4)), isNull);
  });

  test('blocks above removed ones stay where they are', () async {
    put("P", 0, 4);
    put("P", 0, 3);
    final above = grid.findExistingBlockAt(IntVector2(0, 3));

    await run(solved([IntVector2(0, 4)]), [IntVector2(0, 4)]);

    expect(grid.findExistingBlockAt(IntVector2(0, 3)), same(above));
  });
}
