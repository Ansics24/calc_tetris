import 'dart:math';

/// Decides in which column a new block enters the grid.
abstract interface class StartColumnChooser {
  /// Returns the leftmost column of the block, so that it fits completely
  /// into the grid.
  int choose({required int blockWidth, required int gridWidth});
}

class RandomStartColumnChooser implements StartColumnChooser {
  final Random _random;

  RandomStartColumnChooser({Random? random}) : _random = random ?? Random();

  @override
  int choose({required int blockWidth, required int gridWidth}) {
    if (blockWidth > gridWidth) {
      throw ArgumentError.value(
        blockWidth,
        'blockWidth',
        'must not exceed the grid width $gridWidth',
      );
    }
    return _random.nextInt(gridWidth - blockWidth + 1);
  }
}
