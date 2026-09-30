import 'dart:math';

import 'package:calc_tetris/core/block/seed/shapes/compound_block_shape.dart';

class ShapeChooser {
  final Random _random = Random();

  CompoundBlockShape next() {
    return CompoundBlockShape.values[_random.nextInt(
      CompoundBlockShape.values.length,
    )];
  }
}
