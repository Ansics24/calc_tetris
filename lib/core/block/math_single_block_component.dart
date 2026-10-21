import 'dart:async';

import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:flame/components.dart';

abstract class MathSingleBlockComponent<M> extends MathBlockComponent {
  final double? _cellSize;

  /// Without a [cellSize] the block takes the cell size of its [Grid] parent.
  MathSingleBlockComponent({double? cellSize}) : _cellSize = cellSize;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(_cellSize ?? findParent<Grid>()!.cellSize);
  }

  M get model;
}
