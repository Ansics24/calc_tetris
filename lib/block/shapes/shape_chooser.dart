import 'dart:math';

import 'package:magic_blocks/block/shapes/compound_block_shape.dart';

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
