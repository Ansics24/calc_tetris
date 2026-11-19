import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/model/math_operant_block.dart';
import 'package:calc_tetris/block/math/model/math_operant_type.dart';
import 'package:calc_tetris/screens/tutorial/block_rows.dart';
import 'package:test/test.dart';

void main() {
  test('indexes the blocks as [x][y] with y growing downwards', () {
    final blocks = blocksFromRows(['2+', '.=']);

    expect(blocks, hasLength(2));
    expect(blocks[0], hasLength(2));
    expect((blocks[0][0] as MathNumberBlock).number, 2);
    expect(blocks[0][1], isNull);
    expect(
      (blocks[1][0] as MathOperantBlock).type,
      MathOperandType.plus,
    );
    expect(blocks[1][1], isA<MathEqualsBlock>());
  });

  test('turns a dot into an empty cell', () {
    expect(blocksFromRows(['.']), [
      [null],
    ]);
  });

  test('understands minus and multi digit rows', () {
    final blocks = blocksFromRows(['12-']);

    expect((blocks[0][0] as MathNumberBlock).number, 1);
    expect((blocks[1][0] as MathNumberBlock).number, 2);
    expect(
      (blocks[2][0] as MathOperantBlock).type,
      MathOperandType.minus,
    );
  });

  test('gives every block an id of its own', () {
    final blocks = blocksFromRows(['11']);

    expect(blocks[0][0]!.id, isNot(blocks[1][0]!.id));
  });
}
