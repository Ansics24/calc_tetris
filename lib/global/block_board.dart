import 'dart:async';

import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_position.dart';
import 'package:flame/components.dart';

class BlockBoard extends PositionComponent {
  BlockBoard({super.size, super.position});

  @override
  FutureOr<void> onLoad() {
    add(Grid(blockCount: GridPosition(9, 14)));
    return super.onLoad();
  }
}
