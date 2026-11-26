import 'package:magic_blocks/block/math/math_single_block_component_factory.dart';
import 'package:magic_blocks/block/math/seed/generators/random_compoundblock_model_generator.dart';
import 'package:magic_blocks/block/math/seed/next_block_planner.dart';
import 'package:magic_blocks/block/solution_strategy.dart';
import 'package:magic_blocks/grid/endless_game_grid_controller.dart';
import 'package:magic_blocks/grid/grid.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

/// Never used in tests that do not let a block land.
class UnusedStrategy implements SolutionStrategy {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('strategy must not be used');
}

/// A grid to be used as parent of test blocks.
Grid newTestGrid(
  IntVector2 size, {
  NextBlockPlanner? nextBlockPlanner,
}) => Grid(
  blockCount: size,
  singleBlockComponentFactory: newComponentFromBlockModel,
  controllerFactory: (gridModel, grid) => EndlessGameGridController(
    gridModel: gridModel,
    grid: grid,
    solutionStrategy: UnusedStrategy(),
    nextBlockPlanner:
        nextBlockPlanner ??
        NextBlockPlanner(generator: RandomCompoundblockModelGenerator()),
    singleBlockComponentFactory: newComponentFromBlockModel,
  ),
);

extension EndlessGridTestAccess on Grid {
  /// The controller of the grid as the [EndlessGameGridController].
  EndlessGameGridController get endlessController =>
      controller as EndlessGameGridController;
}
