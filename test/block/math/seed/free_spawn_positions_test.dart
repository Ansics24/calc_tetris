import 'package:magic_blocks/block/math/model/math_number_block.dart';
import 'package:magic_blocks/block/math/seed/free_spawn_positions.dart';
import 'package:magic_blocks/block/model/null_block.dart';
import 'package:magic_blocks/block/model/single_block.dart';
import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:test/test.dart';

import '../sample_grids/sample_grid_alternating_columns_5x1.dart';
import '../sample_grids/sample_grid_border_blocked_4x4.dart';
import '../sample_grids/sample_grid_center_blocked_3x2.dart';
import '../sample_grids/sample_grid_empty_4x3.dart';
import '../sample_grids/sample_grid_top_row_blocked_3x3.dart';

SingleBlock _n() => MathNumberBlock(number: 1);

/// A block that is [width] columns wide and one row high, indexed `[x][y]`.
List<List<SingleBlock>> _horizontal(int width) =>
    List.generate(width, (_) => [_n()]);

List<(int, int)> _free(List<List<SingleBlock>> block, GridModel gridModel) =>
    freeSpawnPositions(
      block: block,
      gridModel: gridModel,
    ).map((p) => (p.x, p.y)).toList();

void main() {
  test('on an empty grid a single cell may start at every border cell', () {
    final positions = _free(_horizontal(1), getEmpty4x3SampleModel());

    expect(
      positions,
      unorderedEquals([
        for (var x = 0; x < 4; x++)
          for (var y = 0; y < 3; y++)
            if (x == 0 || y == 0 || x == 3 || y == 2) (x, y),
      ]),
    );
  });

  test('a block may start at the top, bottom, left and right border', () {
    final positions = _free(_horizontal(2), getEmpty4x3SampleModel());

    expect(
      positions,
      unorderedEquals([
        (0, 0), (1, 0), (2, 0), // touches the top
        (0, 1), (0, 2), (1, 2), (2, 2), // touches left and bottom
        (2, 1), // touches the right border
      ]),
    );
  });

  test('a block that touches no border is not offered while the border '
      'has room', () {
    final positions = _free(_horizontal(2), getEmpty4x3SampleModel());

    expect(positions, isNot(contains((1, 1))));
  });

  test('a blocked top row still offers the other borders', () {
    final positions = _free(
      _horizontal(1),
      getTopRowBlocked3x3SampleModel(),
    );

    // the free inner cell (1,1) is not offered as the border has room
    expect(
      positions,
      unorderedEquals([(0, 1), (2, 1), (0, 2), (1, 2), (2, 2)]),
    );
  });

  test('falls back to inner positions when the border is fully blocked', () {
    final positions = _free(
      _horizontal(1),
      getBorderBlocked4x4SampleModel(),
    );

    expect(positions, unorderedEquals([(1, 1), (2, 1), (1, 2), (2, 2)]));
  });

  test('is empty when the block fits nowhere', () {
    final positions = _free(
      _horizontal(2),
      getAlternatingColumns5x1SampleModel(),
    );

    expect(positions, isEmpty);
  });

  test('is empty for a block larger than the grid', () {
    expect(_free(_horizontal(5), getEmpty4x3SampleModel()), isEmpty);
  });

  test('empty cells of the block do not collide', () {
    final block = [
      [_n(), NullBlock()],
      [NullBlock(), _n()],
    ];

    // at (0,0) the block covers (0,0) and (1,1), which is blocked
    final positions = _free(block, getCenterBlocked3x2SampleModel());

    expect(positions, [(1, 0)]);
  });

  test('cells below the top row of the block are checked as well', () {
    final block = [
      [_n(), _n()],
    ];

    final positions = _free(block, getCenterBlocked3x2SampleModel());

    // (1,0) would cover the blocked cell (1,1)
    expect(positions, unorderedEquals([(0, 0), (2, 0)]));
  });
}
