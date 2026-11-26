import 'dart:math';

import 'package:magic_blocks/block/math/seed/spawn_position_chooser.dart';
import 'package:magic_blocks/util/int_vector_2.dart';
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
  final candidates = [IntVector2(0, 0), IntVector2(4, 0), IntVector2(0, 3)];

  test('only chooses among the given candidates', () {
    final chooser = RandomSpawnPositionChooser(random: Random(1));

    for (var i = 0; i < 200; i++) {
      expect(candidates, contains(chooser.choose(candidates)));
    }
  });

  test('draws from exactly the number of candidates', () {
    final random = _ScriptedRandom([2]);
    final chooser = RandomSpawnPositionChooser(random: random);

    final position = chooser.choose(candidates);

    expect(random.requestedBounds, [3]);
    expect(position, same(candidates[2]));
  });

  test('rejects an empty list of candidates', () {
    final chooser = RandomSpawnPositionChooser(random: Random(1));

    expect(() => chooser.choose([]), throwsStateError);
  });

  test('can be used as SpawnPositionChooser', () {
    final SpawnPositionChooser chooser = RandomSpawnPositionChooser();

    final only = IntVector2(1, 1);

    expect(chooser.choose([only]), same(only));
  });
}
