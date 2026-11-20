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

class _OneCellGenerator implements CompoundblockModelGenerator {
  @override
  List<List<SingleBlock>> generate() => [
    [MathNumberBlock(number: 1)],
  ];
}

GridController _controller() {
  final size = IntVector2(5, 5);
  final planner = NextBlockPlanner(generator: _OneCellGenerator());
  final grid = newTestGrid(size, nextBlockPlanner: planner);
  final model = GridModel(size: size, gridComponent: grid)..cellSize = 50;
  return GridController(
    gridModel: model,
    grid: grid,
    solutionStrategy: UnusedStrategy(),
    nextBlockPlanner: planner,
    singleBlockComponentFactory: newComponentFromBlockModel,
  );
}

void main() {
  group('placing the current block', () {
    test('does not happen without a block', () {
      expect(_controller().placeCurrentBlock(), isFalse);
    });

    test('starts the landing and says so', () {
      final controller = _controller()..spawnNextBlock();

      expect(controller.placeCurrentBlock(), isTrue);
    });

    test('says no to a second request while the block is landing', () {
      final controller = _controller()..spawnNextBlock();
      controller.placeCurrentBlock();

      expect(controller.placeCurrentBlock(), isFalse);
    });
  });
}
