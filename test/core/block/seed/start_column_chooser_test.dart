import 'dart:math';

import 'package:calc_tetris/core/block/seed/start_column_chooser.dart';
import 'package:test/test.dart';

/// Returns the scripted values and records the bounds it was asked for.
class _ScriptedRandom implements Random {
  final List<int> _values;
  final List<int> requestedBounds = [];
  int _next = 0;

  _ScriptedRandom(this._values);

  @override
  int nextInt(int max) {
    requestedBounds.add(max);
    return _values[_next++];
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  test('chosen column always lets the whole block fit into the grid', () {
    final chooser = RandomStartColumnChooser(random: Random(1));

    for (var i = 0; i < 500; i++) {
      final column = chooser.choose(blockWidth: 3, gridWidth: 9);
      expect(column, inInclusiveRange(0, 9 - 3));
    }
  });

  test('draws from exactly the columns the block fits into', () {
    final random = _ScriptedRandom([0, 6]);
    final chooser = RandomStartColumnChooser(random: random);

    final first = chooser.choose(blockWidth: 3, gridWidth: 9);
    final last = chooser.choose(blockWidth: 3, gridWidth: 9);

    // columns 0..6 are possible, so the bound is exclusive 7
    expect(random.requestedBounds, [7, 7]);
    expect([first, last], [0, 6]);
  });

  test('a block as wide as the grid starts in the first column', () {
    final chooser = RandomStartColumnChooser(random: Random(1));

    expect(chooser.choose(blockWidth: 4, gridWidth: 4), 0);
  });

  test('a block wider than the grid is rejected', () {
    final chooser = RandomStartColumnChooser(random: Random(1));

    expect(
      () => chooser.choose(blockWidth: 5, gridWidth: 4),
      throwsArgumentError,
    );
  });

  test('can be used as StartColumnChooser', () {
    final StartColumnChooser chooser = RandomStartColumnChooser();

    expect(chooser.choose(blockWidth: 1, gridWidth: 1), 0);
  });
}
