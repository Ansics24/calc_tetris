import 'package:magic_blocks/block/math/appearance/block_tile.dart';
import 'package:magic_blocks/block/math/appearance/tile_colors.dart';
import 'package:magic_blocks/block/math/model/math_number_block.dart';
import 'package:magic_blocks/block/single_block_component.dart';
import 'package:flutter/painting.dart';

class MathNumberBlockComponent extends SingleBlockComponent<MathNumberBlock> {
  final MathNumberBlock _model;

  MathNumberBlockComponent({required this._model, super.cellSize});

  @override
  void onLoad() async {
    await super.onLoad();
    add(
      BlockTile(
        color: TileColors.forDigit(_model.number),
        symbol: _model.number.toString(),
        size: size,
      ),
    );
  }

  @override
  MathNumberBlock get model => _model;

  @override
  Color get shatterColor => TileColors.forDigit(_model.number).base;
}
