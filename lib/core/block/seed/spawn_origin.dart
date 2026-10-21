import 'package:flame/components.dart';

/// Where a new block comes from, so it can be animated into the grid.
abstract interface class SpawnOrigin {
  /// Top left corner of the block as it is shown right now.
  Vector2 get absoluteTopLeft;

  /// On-screen size of one cell of the block as it is shown right now.
  double get cellSize;
}
