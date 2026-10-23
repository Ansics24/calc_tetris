import 'package:calc_tetris/block/compound_block_component.dart';
import 'package:calc_tetris/block/math/math_single_block_component_factory.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/grid_controller.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';

import '../support/test_grid.dart';

class _TwoWideGenerator implements CompoundblockModelGenerator {
  @override
  List<List<SingleBlock>> generate() => [
    [MathNumberBlock(number: 1)],
    [MathNumberBlock(number: 2)],
  ];
}

void main() {
  test('spawns the planned block as a compound block component', () {
    final size = IntVector2(5, 5);
    final planner = NextBlockPlanner(generator: _TwoWideGenerator());
    final grid = newTestGrid(size, nextBlockPlanner: planner);
    final model = GridModel(size: size, gridComponent: grid)..cellSize = 50;
    final planned = planner.upcoming;
    final controller = GridController(
      gridModel: model,
      grid: grid,
      solutionStrategy: UnusedStrategy(),
      nextBlockPlanner: planner,
      singleBlockComponentFactory: newComponentFromBlockModel,
    );

    controller.spawnNextBlock();

    final block = controller.currentBlock;
    expect(block, isA<CompoundBlockComponent>());
    expect(identical(block!.model, planned), isTrue);
    expect(controller.currentBlockGridPosition, isNotNull);
  });
}
