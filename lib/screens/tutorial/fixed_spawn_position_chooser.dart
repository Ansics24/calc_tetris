import 'package:calc_tetris/block/math/seed/spawn_position_chooser.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

/// Lets the block always enter the grid at the same position.
class FixedSpawnPositionChooser implements SpawnPositionChooser {
  final IntVector2 _position;

  FixedSpawnPositionChooser(this._position);

  @override
  IntVector2 choose(List<IntVector2> candidates) {
    final isFree = candidates.any(
      (c) => c.x == _position.x && c.y == _position.y,
    );
    if (!isFree) {
      throw StateError('Spawn position $_position is not free');
    }
    return _position;
  }
}
