import 'package:calc_tetris/block/block_fall_planner.dart';
import 'package:calc_tetris/block/math/math_equals_block_component.dart';
import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/grid/model/grid_single_block_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';

/// Grid coordinates: x = column (left to right), y = row (top to bottom).
/// Blocks fall towards higher y. The bottom row of a 5x5 grid is y = 4.
void main() {
  late GridModel grid;
  final planner = BlockFallPlanner();

  setUp(() {
    grid = GridModel(
      size: IntVector2(5, 5),
      gridComponent: Grid(blockCount: IntVector2(5, 5)),
    );
    grid.cellSize = 50;
  });

  void put(String placementId, int x, int y) {
    grid.addSingleBlock(
      placementId,
      MathEqualsBlockComponent(model: MathEqualsBlock()),
      IntVector2(x, y),
    );
  }

  GridSingleBlockModel at(int x, int y) =>
      grid.findExistingBlockAt(IntVector2(x, y))!;

  List<GridSingleBlockModel> removed(List<IntVector2> positions) =>
      positions.map((p) => at(p.x, p.y)).toList();

  group('BlockFallPlanner.plan', () {
    test('nothing above the removed block => no moves', () {
      put('A', 0, 4);

      final moves = planner.plan(grid, removed([IntVector2(0, 4)]));

      expect(moves, isEmpty);
    });

    test('block directly above a removed block falls by one', () {
      put('A', 0, 4); // will be removed
      put('B', 0, 3);

      final moves = planner.plan(grid, removed([IntVector2(0, 4)]));

      expect(moves, hasLength(1));
      expect(moves.single.block, same(at(0, 3)));
      expect(moves.single.from.toString(), IntVector2(0, 3).toString());
      expect(moves.single.to.toString(), IntVector2(0, 4).toString());
    });

    test('whole stack above falls by the number of removed blocks below', () {
      put('A', 0, 4); // removed
      put('A', 0, 3); // removed
      put('B', 0, 2);
      put('C', 0, 1);

      final moves = planner.plan(
        grid,
        removed([IntVector2(0, 4), IntVector2(0, 3)]),
      );

      final targets = {for (var m in moves) m.block: m.to.y};
      expect(moves, hasLength(2));
      expect(targets[at(0, 2)], 4);
      expect(targets[at(0, 1)], 3);
    });

    test('non-contiguous removals: blocks rest on remaining blocks', () {
      put('A', 0, 4); // stays (supports D)
      put('B', 0, 3); // removed
      put('C', 0, 2); // stays, falls onto A
      put('D', 0, 1);

      final moves = planner.plan(grid, removed([IntVector2(0, 3)]));

      final targets = {for (var m in moves) m.block: m.to.y};
      expect(targets[at(0, 2)], 3);
      expect(targets[at(0, 1)], 2);
      expect(moves, hasLength(2));
    });

    test('blocks in other columns without relation do not move', () {
      put('A', 0, 4); // removed
      put('B', 0, 3);
      put('X', 3, 2); // floating, unrelated, other column

      final moves = planner.plan(grid, removed([IntVector2(0, 4)]));

      expect(moves.map((m) => m.block), isNot(contains(at(3, 2))));
    });

    test('connected block (same placementId) in another column falls too', () {
      // Piece P: (1,4) and (2,3) - (2,3) overhangs the empty cell (2,4).
      put('P', 1, 4); // removed
      put('P', 2, 3);

      final moves = planner.plan(grid, removed([IntVector2(1, 4)]));

      expect(moves, hasLength(1));
      expect(moves.single.block, same(at(2, 3)));
      expect(moves.single.to.toString(), IntVector2(2, 4).toString());
    });

    test('previously connected blocks may be broken apart', () {
      // Piece P is a horizontal pair at (1,3) and (2,3).
      // (1,4) is removed, (2,4) is a different, remaining block.
      put('P', 1, 3);
      put('P', 2, 3);
      put('R', 1, 4); // removed
      put('S', 2, 4);

      final moves = planner.plan(grid, removed([IntVector2(1, 4)]));

      expect(moves, hasLength(1));
      expect(moves.single.block, same(at(1, 3)));
      expect(moves.single.to.toString(), IntVector2(1, 4).toString());
      // (2,3) stays => not part of any move
    });

    test('falling stops at the grid floor', () {
      put('A', 0, 3); // removed
      put('B', 0, 2);

      final moves = planner.plan(grid, removed([IntVector2(0, 3)]));

      expect(moves.single.block, same(at(0, 2)));
      expect(moves.single.to.y, 4); // lands on the floor (last row), not beyond
    });
  });

  group('GridModel.applyMoves', () {
    test('moves the block models to their new cells', () {
      put('A', 0, 4); // removed
      put('B', 0, 3);
      final blockB = at(0, 3);
      final toRemove = removed([IntVector2(0, 4)]);

      final moves = planner.plan(grid, toRemove);
      grid.removeAll(toRemove);
      grid.applyMoves(moves);

      expect(grid.findExistingBlockAt(IntVector2(0, 4)), same(blockB));
      expect(grid.findExistingBlockAt(IntVector2(0, 3)), isNull);
    });
  });
}
