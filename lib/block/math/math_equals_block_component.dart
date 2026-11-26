import 'package:magic_blocks/block/math/appearance/block_tile.dart';
import 'package:magic_blocks/block/math/appearance/tile_colors.dart';
import 'package:magic_blocks/block/math/model/math_equals_block.dart';
import 'package:magic_blocks/block/single_block_component.dart';
import 'package:flutter/painting.dart';

class MathEqualsBlockComponent extends SingleBlockComponent<MathEqualsBlock> {
  final MathEqualsBlock _model;

  MathEqualsBlockComponent({required this._model, super.cellSize});

  @override
  void onLoad() async {
    await super.onLoad();
    add(BlockTile(color: TileColors.equals, symbol: '=', size: size));
  }

  @override
  MathEqualsBlock get model => _model;

  @override
  Color get shatterColor => TileColors.equals.base;
}
