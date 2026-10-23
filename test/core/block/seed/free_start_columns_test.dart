import 'package:calc_tetris/block/model/math_number_block.dart';
import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/free_start_columns.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:test/test.dart';

MathSingleBlock _n() => MathNumberBlock(number: 1);

/// A block that is [width] columns wide and one row high.
List<List<MathSingleBlock>> _horizontal(int width) =>
    List.generate(width, (_) => [_n()]);

/// A block that is one column wide and [height] rows high.
List<List<MathSingleBlock>> _vertical(int height) => [
  List.generate(height, (_) => _n()),
];

/// Model is indexed [x][y], like the grid.
List<int> _free(
  List<List<MathSingleBlock>> block, {
  int gridWidth = 5,
  Set<(int, int)> blocked = const {},
}) => freeStartColumns(
  block: block,
  gridWidth: gridWidth,
  isBlocked: (p) => blocked.contains((p.x, p.y)),
);

void main() {
  test(
    'all columns a horizontal block fits into are free on an empty grid',
    () {
      expect(_free(_horizontal(3)), [0, 1, 2]);
    },
  );

  test('every column is free for a vertical block on an empty grid', () {
    expect(_free(_vertical(3)), [0, 1, 2, 3, 4]);
  });

  test('a column is not free when a cell of the block would overlap', () {
    final block = [
      [_n()],
      [_n()],
    ];

    // block covers (c,0) and (c+1,0); (2,0) blocks c=1 and c=2
    expect(_free(block, blocked: {(2, 0)}), [0, 3]);
  });

  test('only the top row of the grid is relevant to the start', () {
    final block = [
      [_n()],
    ];

    expect(_free(block, blocked: {(1, 1), (2, 5)}), [0, 1, 2, 3, 4]);
  });

  test('empty cells of the block do not collide', () {
    final block = [
      [_n(), NullBlock()],
      [NullBlock(), _n()],
    ];

    // c=0 covers (0,0) and (1,1) -> free; c=1 covers (1,0) -> blocked
    expect(_free(block, gridWidth: 3, blocked: {(1, 0)}), [0]);
  });

  test('cells below the top row of the block are checked as well', () {
    final block = [
      [_n(), _n()],
    ];

    expect(_free(block, gridWidth: 3, blocked: {(1, 1)}), [0, 2]);
  });

  test('no column is free when the top row is full', () {
    final block = [
      [_n()],
    ];

    expect(
      _free(block, gridWidth: 3, blocked: {(0, 0), (1, 0), (2, 0)}),
      isEmpty,
    );
  });

  test('is empty for a block wider than the grid', () {
    final block = List.generate(4, (_) => [_n()]);

    expect(_free(block, gridWidth: 3), isEmpty);
  });

  test('passes grid positions to the blocked check', () {
    final asked = <IntVector2>[];
    freeStartColumns(
      block: [
        [_n()],
      ],
      gridWidth: 1,
      isBlocked: (p) {
        asked.add(p);
        return false;
      },
    );

    expect(asked.map((p) => (p.x, p.y)), [(0, 0)]);
  });
}
