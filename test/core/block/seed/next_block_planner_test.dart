import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/core/block/seed/next_block_planner.dart';
import 'package:test/test.dart';

class _SequenceGenerator implements CompoundblockModelGenerator {
  int generated = 0;

  @override
  List<List<MathSingleBlock>> generate() {
    generated++;
    return [
      [MathNumberBlock(number: generated)],
    ];
  }
}

int _numberOf(List<List<MathSingleBlock>> model) =>
    (model[0][0] as MathNumberBlock).number;

void main() {
  test('plans the first block right away', () {
    final planner = NextBlockPlanner(generator: _SequenceGenerator());

    expect(_numberOf(planner.upcoming), 1);
  });

  test('upcoming stays the same until the block is taken', () {
    final planner = NextBlockPlanner(generator: _SequenceGenerator());

    expect(identical(planner.upcoming, planner.upcoming), isTrue);
  });

  test('take hands out the planned block', () {
    final planner = NextBlockPlanner(generator: _SequenceGenerator());
    final planned = planner.upcoming;

    expect(identical(planner.take(), planned), isTrue);
  });

  test('take plans a new block afterwards', () {
    final planner = NextBlockPlanner(generator: _SequenceGenerator());

    planner.take();

    expect(_numberOf(planner.upcoming), 2);
  });

  test('blocks are handed out in the order they were planned', () {
    final planner = NextBlockPlanner(generator: _SequenceGenerator());

    final taken = [planner.take(), planner.take(), planner.take()];

    expect(taken.map(_numberOf), [1, 2, 3]);
  });

  test('announces every newly planned block', () {
    final planner = NextBlockPlanner(generator: _SequenceGenerator());
    final announced = <int>[];
    planner.upcomingChanges.listen((model) => announced.add(_numberOf(model)));

    planner.take();
    planner.take();

    expect(announced, [2, 3]);
  });

  test('announces nothing while no block is taken', () {
    final planner = NextBlockPlanner(generator: _SequenceGenerator());
    final announced = <int>[];
    planner.upcomingChanges.listen((model) => announced.add(_numberOf(model)));

    planner.upcoming;

    expect(announced, isEmpty);
  });
}
