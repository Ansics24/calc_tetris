import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/seed/generators/random_compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

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
  solutionStrategy: UnusedStrategy(),
  nextBlockPlanner:
      nextBlockPlanner ??
      NextBlockPlanner(generator: RandomCompoundblockModelGenerator()),
  singleBlockComponentFactory: newComponentFromBlockModel,
);
