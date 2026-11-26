import 'dart:math';

import 'package:magic_blocks/util/int_vector_2.dart';

/// Decides at which grid position a new block enters the grid.
abstract interface class SpawnPositionChooser {
  /// Returns one of the [candidates]. Throws a [StateError] if there is none.
  IntVector2 choose(List<IntVector2> candidates);
}

class RandomSpawnPositionChooser implements SpawnPositionChooser {
  final Random _random;

  RandomSpawnPositionChooser({Random? random}) : _random = random ?? Random();

  @override
  IntVector2 choose(List<IntVector2> candidates) {
    if (candidates.isEmpty) {
      throw StateError('No candidate position to choose from');
    }
    return candidates[_random.nextInt(candidates.length)];
  }
}
