import 'package:calc_tetris/block/math/appearance/block_tile.dart';
import 'package:calc_tetris/block/math/appearance/tile_colors.dart';
import 'package:calc_tetris/block/math/math_single_block_component.dart';
import 'package:calc_tetris/block/math/model/math_equals_block.dart';

class MathEqualsBlockComponent
    extends MathSingleBlockComponent<MathEqualsBlock> {
  final MathEqualsBlock _model;

  MathEqualsBlockComponent({required this._model, super.cellSize});

  @override
  void onLoad() async {
    await super.onLoad();
    add(BlockTile(color: TileColors.equals, symbol: '=', size: size));
  }

  @override
  MathEqualsBlock get model => _model;
}
