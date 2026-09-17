import 'dart:async';

import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:flame/components.dart';

abstract class MathSingleBlockComponent extends MathBlockComponent {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(findParent<Grid>()!.cellSize);
  }
}
