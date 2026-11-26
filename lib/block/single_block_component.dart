import 'dart:async';

import 'package:magic_blocks/block/block_component.dart';
import 'package:magic_blocks/block/model/single_block.dart';
import 'package:magic_blocks/grid/grid.dart';
import 'package:magic_blocks/theme/light_theme.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

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

  /// The color of the particles when the block breaks apart.
  Color get shatterColor => colorScheme.tertiary;
}
