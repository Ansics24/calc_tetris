import 'package:calc_tetris/block/math/appearance/block_tile.dart';
import 'package:calc_tetris/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/appearance/tile_colors.dart';
import 'package:calc_tetris/core/block/math_single_block_component.dart';

class MathNumberBlockComponent
    extends MathSingleBlockComponent<MathNumberBlock> {
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
}
