import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_blocks/block/math/math_single_block_component_factory.dart';
import 'package:magic_blocks/block/math/model/math_number_block.dart';
import 'package:magic_blocks/block/math/seed/compoundblock_model_generator.dart';
import 'package:magic_blocks/block/math/seed/next_block_planner.dart';
import 'package:magic_blocks/block/math/seed/spawn_position_chooser.dart';
import 'package:magic_blocks/block/math/valid_equation_solution_strategy.dart';
import 'package:magic_blocks/block/model/null_block.dart';
import 'package:magic_blocks/block/model/single_block.dart';
import 'package:magic_blocks/grid/endless_game_grid_controller.dart';
import 'package:magic_blocks/grid/grid.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

/// Always an L of three number blocks: `model[x][y]`, bottom right is empty.
class _LShapeGenerator implements CompoundblockModelGenerator {
  @override
  List<List<SingleBlock>> generate() => [
    [MathNumberBlock(number: 1), MathNumberBlock(number: 2)],
    [MathNumberBlock(number: 3), NullBlock()],
  ];
}

class _CenterChooser implements SpawnPositionChooser {
  @override
  IntVector2 choose(List<IntVector2> candidates) => IntVector2(4, 3);
}

/// Shows an empty grid of the game size with its first block arrived.
Future<({FlameGame game, Grid grid})> pumpOutlineGrid(
  WidgetTester tester,
) async {
  final game = FlameGame();
  final grid = Grid(
    blockCount: IntVector2.square(11),
    singleBlockComponentFactory: newComponentFromBlockModel,
    controllerFactory: (gridModel, grid) => EndlessGameGridController(
      gridModel: gridModel,
      grid: grid,
      solutionStrategy: ValidEquationSolutionStrategy(),
      nextBlockPlanner: NextBlockPlanner(generator: _LShapeGenerator()),
      singleBlockComponentFactory: newComponentFromBlockModel,
      spawnPositionChooser: _CenterChooser(),
      powerUpFindChances: const {},
    ),
    size: Vector2(440, 440),
  );
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  game.add(grid);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  return (game: game, grid: grid);
}
