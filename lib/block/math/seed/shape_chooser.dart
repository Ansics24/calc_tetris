import 'dart:math';

import 'package:calc_tetris/block/math/seed/shapes/compound_block_shape.dart';

class ShapeChooser {
  final Random _random = Random();

  CompoundBlockShape next() {
    var choosableShapes = CompoundBlockShape.values
        .where((shape) => shape.enabled)
        .toList();
    return choosableShapes[_random.nextInt(
      choosableShapes.length,
    )];
  }
}
