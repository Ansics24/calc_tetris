import 'dart:math';

/// Decides in which column a new block enters the grid.
abstract interface class StartColumnChooser {
  /// Returns the leftmost column of the block, so that it fits completely
  /// into the grid. If [candidates] is given, only one of them is chosen.
  int choose({
    required int blockWidth,
    required int gridWidth,
    List<int>? candidates,
  });
}

class RandomStartColumnChooser implements StartColumnChooser {
  final Random _random;

  RandomStartColumnChooser({Random? random}) : _random = random ?? Random();

  @override
  int choose({
    required int blockWidth,
    required int gridWidth,
    List<int>? candidates,
  }) {
    if (blockWidth > gridWidth) {
      throw ArgumentError.value(
        blockWidth,
        'blockWidth',
        'must not exceed the grid width $gridWidth',
      );
    }
    if (candidates != null) {
      if (candidates.isEmpty) {
        throw StateError('No candidate column to choose from');
      }
      return candidates[_random.nextInt(candidates.length)];
    }
    return _random.nextInt(gridWidth - blockWidth + 1);
  }
}
