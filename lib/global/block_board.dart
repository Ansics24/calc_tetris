import 'dart:async';

import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/components.dart';

class BlockBoard extends PositionComponent {
  BlockBoard({super.size, super.position});

  @override
  FutureOr<void> onLoad() {
    add(Grid(blockCount: IntVector2(9, 14)));
    return super.onLoad();
  }
}
