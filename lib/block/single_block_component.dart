import 'dart:async';

import 'package:calc_tetris/block/block_component.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:flame/components.dart';

abstract class SingleBlockComponent<M extends SingleBlock>
    extends BlockComponent {
  final double? _cellSize;

  /// Without a [cellSize] the block takes the cell size of its [Grid] parent.
  SingleBlockComponent({this._cellSize});

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(_cellSize ?? findParent<Grid>()!.cellSize);
  }

  M get model;
}
