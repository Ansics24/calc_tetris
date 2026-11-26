import 'package:magic_blocks/block/math/model/math_equals_block.dart';
import 'package:magic_blocks/block/math/model/math_number_block.dart';
import 'package:magic_blocks/block/math/seed/compoundblock_model_generator.dart';
import 'package:magic_blocks/block/math/seed/next_block_planner.dart';
import 'package:magic_blocks/block/model/null_block.dart';
import 'package:magic_blocks/screens/tutorial/scripted_block_generator.dart';
import 'package:test/test.dart';

void main() {
  test('is a generator for compound blocks', () {
    expect(ScriptedBlockGenerator(['=5']), isA<CompoundblockModelGenerator>());
  });

  test('generates the block described by the rows, indexed [x][y]', () {
    final block = ScriptedBlockGenerator(['=5']).generate();

    expect(block, hasLength(2));
    expect(block[0], hasLength(1));
    expect(block[0][0], isA<MathEqualsBlock>());
    expect((block[1][0] as MathNumberBlock).number, 5);
  });

  test('describes a vertical block with one row per cell', () {
    final block = ScriptedBlockGenerator(['8', '=']).generate();

    expect(block, hasLength(1));
    expect((block[0][0] as MathNumberBlock).number, 8);
    expect(block[0][1], isA<MathEqualsBlock>());
  });

  test('fills a dot with a null block', () {
    final block = ScriptedBlockGenerator(['5.']).generate();

    expect(block[1][0], isA<NullBlock>());
  });

  test('generates a fresh copy with new ids on every call', () {
    final generator = ScriptedBlockGenerator(['=5']);

    final first = generator.generate();
    final second = generator.generate();

    expect(identical(first, second), isFalse);
    expect(first[0][0].id, isNot(second[0][0].id));
  });

  test('can be planned like any other generator', () {
    final planner = NextBlockPlanner(generator: ScriptedBlockGenerator(['=5']));

    expect(planner.upcoming[0][0], isA<MathEqualsBlock>());
  });
}
